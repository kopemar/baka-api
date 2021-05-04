require 'test_helper'

class SchedulingTest < ActionDispatch::IntegrationTest
  def auth_tokens_for_user(user)
    # The argument 'user' should be a hash that includes the params 'email' and 'password'.
    post '/api/v1/auth/sign_in/',
         params: {username: user[:username], password: ""},
         as: :json
    # The three categories below are the ones you need as authentication headers.
    response.headers.slice('client', 'access-token', 'uid', 'token-type', 'expiry')
  end

  def generate_employees_1b(s1, s2, s3)
    2.times do
      e = employee_active_contract(@organization)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s2)
      e.contracts.first.specializations.push(s3)
      e.save!
    end

    1.times do
      e = employee_active_contract(@organization)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    2.times do
      e = employee_active_contract(@organization)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    2.times do
      e = employee_active_contract(@organization)
      e.contracts.first.specializations.push(s1)
      e.save!
    end

    1.times do
      e = employee_active_contract(@organization)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s3)
      e.save!
    end

    2.times do
      e = employee_active_contract(@organization)
      e.contracts.first.specializations.push(s3)
      e.save!
    end
  end

  def generate_templates_1b
    @templates.each_with_index do |t, index|
      #t.update(priority: 0)

      if specialization_s1.include? index
        priority = 3
        if specialization_s1_demand_2.include? index
          priority = 2
        end
        create_specialized_template(t, @s1, priority)
      end
      if specialization_s2.include? index
        priority = 3
        create_specialized_template(t, @s2, priority)
      end

      if specialization_s3.include? index
        priority = 2
        create_specialized_template(t, @s3, priority)
      end
    end
  end

  def create_specialized_template(parent_template, specialization, priority)
    ShiftTemplate.create!(
        start_time: parent_template.start_time,
        end_time: parent_template.end_time,
        break_minutes: parent_template.break_minutes,
        priority: priority,
        organization_id: @organization.id,
        is_employment_contract: parent_template.is_employment_contract,
        parent_template_id: parent_template.id,
        specialization_id: specialization.id
    )
  end

  def specialization_s1
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  end

  def specialization_s1_demand_2
    [3, 7, 8, 9]
  end

  def specialization_s1_demand_3
    [0, 1, 2, 4, 5, 6]
  end

  def specialization_s2
    [10, 11, 12, 13]
  end

  def specialization_s3
    [0, 2, 4, 6, 8]
  end

  test "R1 – RANDOM Algorithm Test " do
    with_priorities({})
  end

  test "R2 – SPECIALIZED ONLY Algorithm Test " do
    with_priorities({:specialized_preferred => 10})
  end

  test "R3 Algorithm Test " do
    with_priorities({:no_empty_shifts => 10})
  end

  test "R4 Algorithm Test " do
    with_priorities({:demand_fulfill => 10})
  end

  test "R5 Algorithm Test " do
    with_priorities({:free_days => 10})
  end

  test "R6 Algorithm Test " do
    with_priorities({:free_days => 10, :demand_fulfill => 10, :no_empty_shifts => 10, :specialized_preferred => 10})
  end

  test "R7 Algorithm Test " do
    with_priorities({:no_empty_shifts => 20, :demand_fulfill => 20, :specialized_preferred => 10, :free_days => 10})
  end

  test "R8 Algorithm Test " do
    with_priorities({:no_empty_shifts => 20, :demand_fulfill => 10, :specialized_preferred => 20, :free_days => 10})
  end

  test "R9 Algorithm Test " do
    with_priorities({:no_empty_shifts => 30, :demand_fulfill => 40, :specialized_preferred => 20, :free_days => 10})
  end

  def with_priorities(priorities)
    @organization = generate_organization
    @s1 = Specialization.create(name: "ABC", organization_id: @organization.id)
    @s2 = Specialization.create(name: "DEF", organization_id: @organization.id)
    @s3 = Specialization.create(name: "GHI", organization_id: @organization.id)

    generate_employees_1b(@s1, @s2, @s3)

    user = FactoryBot.create(:manager, organization: @organization)
    @auth_tokens = auth_tokens_for_user(user)

    @period = FactoryBot.create(:scheduling_period, organization_id: @organization.id)
    templates = ShiftTemplateGenerator.call(
        {
            :id => @period.id,
            :working_days => [1, 2, 3, 4, 5, 6, 7],
            :start_time => "09:00",
            :end_time => "18:00",
            :shift_hours => 8,
            :break_minutes => 30,
            :per_day => 2
        }
    )

    @templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: { scheduling_period_id: @period.id }).order("start_time")

    # generate_templates_1b

    Scheduling::Scheduling.new({ id: @period.id, priorities: priorities }).call

    schedule = {}
    Shift.where(shift_template: ShiftTemplate::in_scheduling_period(@period.id)).to_a.group_by { |shift|
      shift.schedule_id
    }.each { |k, v|
      schedule[k] = v.map(&:shift_template_id)
    }

    result = evaluate_solution(schedule)
    Rails.logger.debug @templates

    Rails.logger.debug "🌫 :no_empty_shifts #{result[:no_empty_shifts][:sanction]}"
    Rails.logger.debug "🌫 :demand_fulfill #{result[:demand_fulfill][:sanction]}"
    Rails.logger.debug "🌫 :specialized_preferred #{result[:specialized_preferred][:sanction]}"
    Rails.logger.debug "🌫 :free_days #{result[:free_days][:sanction]}"
  end

  def evaluate_solution(solution)
    templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: { scheduling_period_id: @period.id }).order("start_time")
    violations = Hash.new

    # exclude shifts with no priority
    violations[:no_empty_shifts] = Scheduling::NoEmptyShifts.get_violations_hash(templates.filter { |s| s.priority > 0 }, solution, 1)

    violations[:demand_fulfill] = Scheduling::DemandFulfill.get_violations_hash(templates.filter { |s| s.priority > 0 }, solution, 1)

    violations[:specialized_preferred] =  Scheduling::SpecializedPreferred.get_violations_hash(templates.filter { |s| s.priority > 0 }, solution, 1)

    violations[:free_days] = Scheduling::FreeDaysInRow.get_violations_hash(templates, solution, @period, 1)
    violations
  end
end