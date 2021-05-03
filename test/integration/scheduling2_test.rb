require 'test_helper'

class Scheduling2Test < ActionDispatch::IntegrationTest



  def auth_tokens_for_user(user)
    # The argument 'user' should be a hash that includes the params 'email' and 'password'.
    post '/api/v1/auth/sign_in/',
         params: {username: user[:username], password: ""},
         as: :json
    # The three categories below are the ones you need as authentication headers.
    response.headers.slice('client', 'access-token', 'uid', 'token-type', 'expiry')
  end

  def generate_period(auth_tokens, org)
    period = FactoryBot.create(:scheduling_period, organization: org)
    post "/api/v1/periods/#{period.id}/shift-templates",
         params: {
             working_days: [1, 2, 3, 4, 5],
             start_time: "08:00",
             end_time: "18:30",
             shift_hours: 8,
             break_minutes: 30,
             per_day: 4
         },
         headers: @auth_tokens

    assert_response :success
    SchedulingPeriod.where(id: period.id).first
  end

  def generate_employees_1a(s1, s2)
    3.times do
      e = employee_active_contract(@organization)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    4.times do
      e = employee_active_contract(@organization)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    4.times do
      e = employee_active_contract(@organization)
      e.contracts.first.specializations.push(s1)
      e.save!
    end

    4.times do
      e = employee_active_contract(@organization)
    end
  end

  def generate_templates_1a
    @templates.each_with_index do |t, index|
      if demand_1.include? index
        t.update(priority: 1)
      elsif demand_2.include? index
        t.update(priority: 2)
      elsif demand_3.include? index
        t.update(priority: 3)
      elsif demand_4.include? index
        t.update(priority: 4)
      end

      if specialization_s1.include? index
        priority = 2
        if specialization_s1_demand_1.include? index
          priority = 1
        end
        create_specialized_template(t, @s1, priority)
      end
      if specialization_s2.include? index
        priority = 2
        if specialization_s2_demand_1.include? index
          priority = 1
        elsif specialization_s2_demand_3.include? index
          priority = 3
        end
        create_specialized_template(t, @s2, priority)
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

  def demand_1
    [0, 1, 2, 4, 5, 7, 8, 11, 15, 18, 20]
  end

  def demand_2
    [3, 6, 9, 10, 12, 14, 17, 19]
  end

  def demand_3
    [16]
  end

  def demand_4
    [13]
  end

  def specialization_s1
    [0, 3, 6, 9, 12, 15, 18]
  end

  def specialization_s1_demand_1
    [15, 18]
  end

  def specialization_s1_demand_2
    [0, 3, 6, 9, 12]
  end

  def specialization_s2
    [1, 3, 4, 6, 7, 9, 10, 12, 13, 15, 16, 18, 19]
  end

  def specialization_s2_demand_1
    [1, 3, 4, 6, 7, 9, 16, 18, 19]
  end

  def specialization_s2_demand_2
    [10]
  end

  def specialization_s2_demand_3
    [12, 13, 15]
  end

  # test "R1 – RANDOM Algorithm Test " do
  #   with_priorities({})
  # end

  # test "R2 – SPECIALIZED ONLY Algorithm Test " do
  #   with_priorities({:specialized_preferred => 10})
  # end

  # test "R3 Algorithm Test " do
  #   with_priorities({:no_empty_shifts => 10})
  # end
  #
  # test "R4 Algorithm Test " do
  #   with_priorities({:demand_fulfill => 10})
  # end

  test "R5 Algorithm Test " do
    with_priorities({:free_days => 10})
  end

  # test "R6 Algorithm Test " do
  #   with_priorities({:free_days => 10, :demand_fulfill => 10, :no_empty_shifts => 10, :specialized_preferred => 10})
  # end
  #
  # test "R7 Algorithm Test " do
  #   with_priorities({:no_empty_shifts => 20, :demand_fulfill => 20, :specialized_preferred => 10, :free_days => 10})
  # end
  #
  # test "R8 Algorithm Test " do
  #   with_priorities({:no_empty_shifts => 20, :demand_fulfill => 10, :specialized_preferred => 20, :free_days => 10})
  # end
  #
  # test "R9 Algorithm Test " do
  #   with_priorities({:no_empty_shifts => 30, :demand_fulfill => 40, :specialized_preferred => 20, :free_days => 10})
  # end

  def with_priorities(priorities)
    @organization = generate_organization
    @s1 = Specialization.create(name: "ABC", organization_id: @organization.id)
    @s2 = Specialization.create(name: "DEF", organization_id: @organization.id)

    generate_employees_1a(@s1, @s2)

    user = FactoryBot.create(:manager, organization: @organization)
    @auth_tokens = auth_tokens_for_user(user)

    @period = FactoryBot.create(:scheduling_period, organization_id: @organization.id)
    templates = ShiftTemplateGenerator.call(
        {
            :id => @period.id,
            :working_days => [1, 2, 3, 4, 5, 6, 7],
            :start_time => "08:00",
            :end_time => "03:00",
            :shift_hours => 8,
            :break_minutes => 30,
            :per_day => 3,
            :night_shift => true
        }
    )

    @templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: { scheduling_period_id: @period.id }).order("start_time")

    generate_templates_1a

    Scheduling::Scheduling.new({ id: @period.id, priorities: priorities }).call

    schedule = {}
    Shift.where(shift_template: ShiftTemplate::in_scheduling_period(@period.id)).to_a.group_by { |shift|
      shift.schedule_id
    }.each { |k, v|
      schedule[k] = v.map(&:shift_template_id)
    }

    # [:no_empty_shifts] = Scheduling::NoEmptyShifts.get_violations_hash(templates.filter { |s| s.priority > 0 }, solution, 1)
    #
    # violations[:demand_fulfill] = Scheduling::DemandFulfill.get_violations_hash(templates.filter { |s| s.priority > 0 }, solution, 1)
    #
    # violations[:specialized_preferred] =  Scheduling::SpecializedPreferred.get_violations_hash(templates.filter { |s| s.priority > 0 }, solution, 1)
    #
    # violations[:free_days]

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

    violations[:free_days] = Scheduling::FreeDaysInRow.get_violations_hash(templates.filter { |s| s.priority > 0 }, solution, @period, 1)
    violations
  end
end
