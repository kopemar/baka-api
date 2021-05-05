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

  test "A R1 – RANDOM Algorithm Test " do
    with_priorities_a({})
  end

  test "A R2 – SPECIALIZED ONLY Algorithm Test " do
    with_priorities_a({:specialized_preferred => 10})
  end

  test "A R3 Algorithm Test " do
    with_priorities_a({:no_empty_shifts => 10})
  end

  test "A R4 Algorithm Test " do
    with_priorities_a({:demand_fulfill => 10})
  end

  test "A R5 Algorithm Test " do
    with_priorities_a({:free_days => 10})
  end

  test "A R6 Algorithm Test " do
    with_priorities_a({:free_days => 10, :demand_fulfill => 10, :no_empty_shifts => 10, :specialized_preferred => 10})
  end

  test "A R7 Algorithm Test " do
    with_priorities_a({:no_empty_shifts => 20, :demand_fulfill => 20, :specialized_preferred => 10, :free_days => 10})
  end

  test "A R8 Algorithm Test " do
    with_priorities_a({:no_empty_shifts => 20, :demand_fulfill => 10, :specialized_preferred => 20, :free_days => 10})
  end

  test "A R9 Algorithm Test " do
    with_priorities_a({:no_empty_shifts => 30, :demand_fulfill => 40, :specialized_preferred => 20, :free_days => 10})
  end

  def with_priorities_a(priorities)
    @org = generate_organization
    @s1 = Specialization.create(name: "ABC", organization_id: @org.id)
    @s2 = Specialization.create(name: "DEF", organization_id: @org.id)

    OrganizationFactory.generate_employees_1a(@s1, @s2, @org)

    user = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(user)

    @period = FactoryBot.create(:scheduling_period, organization_id: @org.id)
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

    TemplatesFactory.generate_templates_1a(@templates, @s1, @s2, @org)

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


    open('a-data.csv', 'a') do |f|
      f << "#{priorities[:no_empty_shifts] || 0},#{priorities[:demand_fulfill] || 0},#{priorities[:specialized_preferred] || 0},#{priorities[:free_days] || 0},#{result[:no_empty_shifts][:sanction]},#{result[:demand_fulfill][:sanction]},#{result[:specialized_preferred][:sanction]},#{result[:free_days][:sanction]}\n"
    end

    Rails.logger.debug "🌫 :no_empty_shifts #{result[:no_empty_shifts][:sanction]}"
    Rails.logger.debug "🌫 :demand_fulfill #{result[:demand_fulfill][:sanction]}"
    Rails.logger.debug "🌫 :specialized_preferred #{result[:specialized_preferred][:sanction]}"
    Rails.logger.debug "🌫 :free_days #{result[:free_days][:sanction]}"
  end

  def with_priorities(priorities)
    @org = generate_organization
    @s1 = Specialization.create(name: "ABC", organization_id: @org.id)
    @s2 = Specialization.create(name: "DEF", organization_id: @org.id)
    @s3 = Specialization.create(name: "GHI", organization_id: @org.id)

    OrganizationFactory.generate_employees_1b(@s1, @s2, @s3, @org)

    user = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(user)

    @period = FactoryBot.create(:scheduling_period, organization_id: @org.id)
    templates = ShiftTemplateGenerator.call(
        {
            :id => @period.id,
            :working_days => [1, 2, 3, 4, 5, 6, 7],
            :start_time => "08:00",
            :end_time => "17:30",
            :shift_hours => 8,
            :break_minutes => 30,
            :per_day => 2
        }
    )

    @templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: { scheduling_period_id: @period.id }).order("start_time")

    TemplatesFactory.generate_templates_1b(@templates, @s1, @s2, @s3, @org)

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

    open('b-data.csv', 'a') do |f|
      f << "#{priorities[:no_empty_shifts] || 0},#{priorities[:demand_fulfill] || 0},#{priorities[:specialized_preferred] || 0},#{priorities[:free_days] || 0},#{result[:no_empty_shifts][:sanction]},#{result[:demand_fulfill][:sanction]},#{result[:specialized_preferred][:sanction]},#{result[:free_days][:sanction]}\n"
    end
  end

  def with_priorities_c(priorities)
    @org = generate_organization
    @s1 = Specialization.create(name: "ABC", organization_id: @org.id)
    @s2 = Specialization.create(name: "DEF", organization_id: @org.id)
    @s3 = Specialization.create(name: "GHI", organization_id: @org.id)
    @s4 = Specialization.create(name: "JKL", organization_id: @org.id)


    OrganizationFactory.generate_employees_1c(@s1, @s2, @s3, @org)

    user = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(user)

    @period = FactoryBot.create(:scheduling_period, organization_id: @org.id)
    templates = ShiftTemplateGenerator.call(
        {
            :id => @period.id,
            :working_days => [1, 2, 3, 4, 5, 6, 7],
            :start_time => "08:00",
            :end_time => "17:30",
            :shift_hours => 8,
            :break_minutes => 30,
            :per_day => 2
        }
    )

    @templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: { scheduling_period_id: @period.id }).order("start_time")

    TemplatesFactory.generate_templates_1b(@templates, @s1, @s2, @s3, @org)

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

    open('b-data.csv', 'a') do |f|
      f << "#{priorities[:no_empty_shifts] || 0},#{priorities[:demand_fulfill] || 0},#{priorities[:specialized_preferred] || 0},#{priorities[:free_days] || 0},#{result[:no_empty_shifts][:sanction]},#{result[:demand_fulfill][:sanction]},#{result[:specialized_preferred][:sanction]},#{result[:free_days][:sanction]}\n"
    end
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