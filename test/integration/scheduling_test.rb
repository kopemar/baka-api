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
    with_priorities_a #({})
  end

  # test "A R2 – SPECIALIZED ONLY Algorithm Test " do
  #   with_priorities_a#({:specialized_preferred => 10})
  # end
  #
  # test "A R3 Algorithm Test " do
  #   with_priorities_a#({:no_empty_shifts => 10})
  # end
  #
  # test "A R4 Algorithm Test " do
  #   with_priorities_a#({:demand_fulfill => 10})
  # end
  #
  # test "A R5 Algorithm Test " do
  #   with_priorities_a#({:free_days => 10})
  # end
  #
  # test "A R6 Algorithm Test " do
  #   with_priorities_a#({:free_days => 10, :demand_fulfill => 10, :no_empty_shifts => 10, :specialized_preferred => 10})
  # end
  #
  # test "A R7 Algorithm Test " do
  #   with_priorities_a#({:no_empty_shifts => 20, :demand_fulfill => 20, :specialized_preferred => 10, :free_days => 10})
  # end
  #
  # test "A R8 Algorithm Test " do
  #   with_priorities_a#({:no_empty_shifts => 20, :demand_fulfill => 10, :specialized_preferred => 20, :free_days => 10})
  # end
  #
  # test "A R9 Algorithm Test " do
  #   with_priorities_a#({:no_empty_shifts => 30, :demand_fulfill => 40, :specialized_preferred => 20, :free_days => 10})
  # end

  test "C R1 – RANDOM Algorithm Test " do
    with_priorities_c({})
  end

  test "C R2 – SPECIALIZED ONLY Algorithm Test " do
    with_priorities_c({:specialized_preferred => 10})
  end

  test "C R3 Algorithm Test " do
    with_priorities_c({:no_empty_shifts => 10})
  end

  test "C R4 Algorithm Test " do
    with_priorities_c({:demand_fulfill => 10})
  end

  test "C R5 Algorithm Test " do
    with_priorities_c({:free_days => 10})
  end

  test "C R6 Algorithm Test " do
    with_priorities_c({:free_days => 10, :demand_fulfill => 10, :no_empty_shifts => 10, :specialized_preferred => 10})
  end

  test "C R7 Algorithm Test " do
    with_priorities_c({:no_empty_shifts => 20, :demand_fulfill => 20, :specialized_preferred => 10, :free_days => 10})
  end

  test "C R8 Algorithm Test " do
    with_priorities_c({:no_empty_shifts => 20, :demand_fulfill => 10, :specialized_preferred => 20, :free_days => 10})
  end

  test "C R9 Algorithm Test " do
    with_priorities_c({:no_empty_shifts => 30, :demand_fulfill => 40, :specialized_preferred => 20, :free_days => 10})
  end

  test "D R1 – RANDOM Algorithm Test " do
    with_priorities_d({})
  end

  test "D R2 – SPECIALIZED ONLY Algorithm Test " do
    with_priorities_d({:specialized_preferred => 10})
  end

  test "D R3 Algorithm Test " do
    with_priorities_d({:no_empty_shifts => 10})
  end

  test "D R4 Algorithm Test " do
    with_priorities_d({:demand_fulfill => 10})
  end

  test "D R5 Algorithm Test " do
    with_priorities_d({:free_days => 10})
  end

  test "D R6 Algorithm Test " do
    with_priorities_d({:free_days => 10, :demand_fulfill => 10, :no_empty_shifts => 10, :specialized_preferred => 10})
  end

  test "D R7 Algorithm Test " do
    with_priorities_d({:no_empty_shifts => 20, :demand_fulfill => 20, :specialized_preferred => 10, :free_days => 10})
  end

  test "D R8 Algorithm Test " do
    with_priorities_d({:no_empty_shifts => 20, :demand_fulfill => 10, :specialized_preferred => 20, :free_days => 10})
  end

  test "D R9 Algorithm Test " do
    with_priorities_d({:no_empty_shifts => 30, :demand_fulfill => 40, :specialized_preferred => 20, :free_days => 10})
  end

  test "E Algorithm Test " do
    with_priorities_e
  end

  test "F Algorithm Test " do
    with_priorities_f
  end

  test "G Algorithm Test " do
    with_priorities_g
  end

  def priorities
    [
        {},
        {:specialized_preferred => 10},
        {:no_empty_shifts => 10},
        {:demand_fulfill => 10},
        {:free_days => 10},
        {:free_days => 10, :demand_fulfill => 10, :no_empty_shifts => 10, :specialized_preferred => 10},
        {:no_empty_shifts => 20, :demand_fulfill => 20, :specialized_preferred => 10, :free_days => 10},
        {:no_empty_shifts => 20, :demand_fulfill => 10, :specialized_preferred => 20, :free_days => 10},
        {:no_empty_shifts => 30, :demand_fulfill => 40, :specialized_preferred => 20, :free_days => 10}
    ]
  end

  def with_priorities_a
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

    @templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: {scheduling_period_id: @period.id}).order("start_time")

    TemplatesFactory.generate_templates_1a(@templates, @s1, @s2, @org)

    priorities.each do |priority|
      Scheduling::Scheduling.new({id: @period.id, priorities: priority}).call

      schedule = {}
      Shift.where(shift_template: ShiftTemplate::in_scheduling_period(@period.id)).to_a.group_by { |shift|
        shift.schedule_id
      }.each { |k, v|
        schedule[k] = v.map(&:shift_template_id)
      }

      result = evaluate_solution(schedule)
      Rails.logger.debug @templates

      open('a-data.csv', 'a') do |f|
        f << "#{priority[:no_empty_shifts] || 0},#{priority[:demand_fulfill] || 0},#{priority[:specialized_preferred] || 0},#{priority[:free_days] || 0},#{result[:no_empty_shifts][:sanction]},#{result[:demand_fulfill][:sanction]},#{result[:specialized_preferred][:sanction]},#{result[:free_days][:sanction]}\n"
      end
    end
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

    @templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: {scheduling_period_id: @period.id}).order("start_time")

    TemplatesFactory.generate_templates_1b(@templates, @s1, @s2, @s3, @org)

    Scheduling::Scheduling.new({id: @period.id, priorities: priorities}).call

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


    OrganizationFactory.generate_employees_1c(@s1, @s2, @s3, @s4, @org)

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

    @templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: {scheduling_period_id: @period.id}).order("start_time")

    TemplatesFactory.generate_templates_1c(@templates, @s1, @s2, @s3, @s4, @org)

    Scheduling::Scheduling.new({id: @period.id, priorities: priorities}).call

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

    open('c-data.csv', 'a') do |f|
      f << "#{priorities[:no_empty_shifts] || 0},#{priorities[:demand_fulfill] || 0},#{priorities[:specialized_preferred] || 0},#{priorities[:free_days] || 0},#{result[:no_empty_shifts][:sanction]},#{result[:demand_fulfill][:sanction]},#{result[:specialized_preferred][:sanction]},#{result[:free_days][:sanction]}\n"
    end
  end

  def with_priorities_d(priorities)
    @org = generate_organization
    @s1 = Specialization.create(name: "ABC", organization_id: @org.id)
    @s2 = Specialization.create(name: "DEF", organization_id: @org.id)
    @s3 = Specialization.create(name: "GHI", organization_id: @org.id)

    OrganizationFactory.generate_employees_1d(@s1, @s2, @s3, @org)

    user = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(user)

    @period = FactoryBot.create(:scheduling_period, organization_id: @org.id)
    templates = ShiftTemplateGenerator.call(
        {
            :id => @period.id,
            :working_days => [1, 2, 3, 4, 5, 6, 7],
            :start_time => "08:00",
            :end_time => "00:30",
            :shift_hours => 8,
            :break_minutes => 30,
            :per_day => 2,
            :night_shift => true
        }
    )

    @templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: {scheduling_period_id: @period.id}).order("start_time")

    TemplatesFactory.generate_templates_1d(@templates, @s1, @s2, @s3, @org)

    5.times do |i|
      Scheduling::Scheduling.new({id: @period.id, priorities: priorities, iterations: i}).call

      schedule = {}
      Shift.where(shift_template: ShiftTemplate::in_scheduling_period(@period.id)).to_a.group_by { |shift|
        shift.schedule_id
      }.each { |k, v|
        schedule[k] = v.map(&:shift_template_id)
      }

      result = evaluate_solution(schedule)
      Rails.logger.debug @templates

      open('d-data.csv', 'a') do |f|
        f << "#{i},#{priorities[:no_empty_shifts] || 0},#{priorities[:demand_fulfill] || 0},#{priorities[:specialized_preferred] || 0},#{priorities[:free_days] || 0},#{result[:no_empty_shifts][:sanction]},#{result[:demand_fulfill][:sanction]},#{result[:specialized_preferred][:sanction]},#{result[:free_days][:sanction]}\n"
      end
    end

  end

  def with_priorities_e
    @org = generate_organization
    @s1 = Specialization.create(name: "ABC", organization_id: @org.id)
    @s2 = Specialization.create(name: "DEF", organization_id: @org.id)

    OrganizationFactory.generate_employees_1e(@s1, @s2, @org)

    user = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(user)

    @period = FactoryBot.create(:scheduling_period, organization_id: @org.id)
    templates = ShiftTemplateGenerator.call(
        {
            :id => @period.id,
            :working_days => [1, 2, 3, 4, 5, 6, 7],
            :start_time => "08:00",
            :end_time => "16:30",
            :shift_hours => 8,
            :break_minutes => 30,
            :per_day => 1,
        }
    )

    @templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: {scheduling_period_id: @period.id}).order("start_time")

    TemplatesFactory.generate_templates_1e(@templates, @s1, @s2, @org)

    1.times do
      priorities.each do |priority|
        5.times do |i|
          Scheduling::Scheduling.new({id: @period.id, priorities: priority, iterations: i}).call

          schedule = {}
          Shift.where(shift_template: ShiftTemplate::in_scheduling_period(@period.id)).to_a.group_by { |shift|
            shift.schedule_id
          }.each { |k, v|
            schedule[k] = v.map(&:shift_template_id)
          }

          result = evaluate_solution(schedule)
          Rails.logger.debug @templates

          open('e-data.csv', 'a') do |f|
            f << "#{i},#{priority[:no_empty_shifts] || 0},#{priority[:demand_fulfill] || 0},#{priority[:specialized_preferred] || 0},#{priority[:free_days] || 0},#{result[:no_empty_shifts][:sanction]},#{result[:demand_fulfill][:sanction]},#{result[:specialized_preferred][:sanction]},#{result[:free_days][:sanction]}\n"
          end
        end
      end
    end
  end

  def with_priorities_f
    @org = generate_organization
    @s1 = Specialization.create(name: "ABC", organization_id: @org.id)
    @s2 = Specialization.create(name: "DEF", organization_id: @org.id)
    @s3 = Specialization.create(name: "GHI", organization_id: @org.id)

    OrganizationFactory.generate_employees_1f(@s1, @s2, @s3, @org)

    user = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(user)

    @period = FactoryBot.create(:scheduling_period, organization_id: @org.id)
    templates = ShiftTemplateGenerator.call(
        {
            :id => @period.id,
            :working_days => [1, 2, 3, 4, 5, 6, 7],
            :start_time => "08:00",
            :end_time => "21:45",
            :shift_hours => 8,
            :break_minutes => 30,
            :per_day => 2,
        }
    )

    @templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: {scheduling_period_id: @period.id}).order("start_time")

    TemplatesFactory.generate_templates_1f(@templates, @s1, @s2, @s3, @org)

    1.times do
      priorities.each do |priority|
        5.times do |i|
          Scheduling::Scheduling.new({id: @period.id, priorities: priority, iterations: i}).call

          schedule = {}
          Shift.where(shift_template: ShiftTemplate::in_scheduling_period(@period.id)).to_a.group_by { |shift|
            shift.schedule_id
          }.each { |k, v|
            schedule[k] = v.map(&:shift_template_id)
          }

          result = evaluate_solution(schedule)
          Rails.logger.debug @templates

          open('f-data.csv', 'a') do |f|
            f << "#{i},#{priority[:no_empty_shifts] || 0},#{priority[:demand_fulfill] || 0},#{priority[:specialized_preferred] || 0},#{priority[:free_days] || 0},#{result[:no_empty_shifts][:sanction]},#{result[:demand_fulfill][:sanction]},#{result[:specialized_preferred][:sanction]},#{result[:free_days][:sanction]}\n"
          end
        end
      end
    end
  end

  def with_priorities_g
    @org = generate_organization
    @s1 = Specialization.create(name: "ABC", organization_id: @org.id)
    @s2 = Specialization.create(name: "DEF", organization_id: @org.id)
    @s3 = Specialization.create(name: "GHI", organization_id: @org.id)

    OrganizationFactory.generate_employees_1g(@s1, @s2, @s3, @org)

    user = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(user)

    @period = FactoryBot.create(:scheduling_period, organization_id: @org.id)
    templates = ShiftTemplateGenerator.call(
        {
            :id => @period.id,
            :working_days => [1, 2, 3, 4, 5],
            :excluded => {
                1 => [4],
                2 => [1, 2],
                3 => [1],
                4 => [4],
                5 => [1]
            },
            :start_time => "08:00",
            :end_time => "02:00",
            :shift_hours => 10,
            :break_minutes => 30,
            :per_day => 4,
            :night_shift => true
        }
    )

    @templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: {scheduling_period_id: @period.id}).order("start_time")

    TemplatesFactory.generate_templates_1g(@templates, @s1, @s2, @s3, @org)

    1.times do
      priorities.each do |priority|
        5.times do |i|
          begin
            Scheduling::Scheduling.new({id: @period.id, priorities: priority, iterations: i}).call
            schedule = {}
            Shift.where(shift_template: ShiftTemplate::in_scheduling_period(@period.id)).to_a.group_by { |shift|
              shift.schedule_id
            }.each { |k, v|
              schedule[k] = v.map(&:shift_template_id)
            }

            result = evaluate_solution(schedule)
            Rails.logger.debug @templates

            open('g-data.csv', 'a') do |f|
              f << "#{i},#{priority[:no_empty_shifts] || 0},#{priority[:demand_fulfill] || 0},#{priority[:specialized_preferred] || 0},#{priority[:free_days] || 0},#{result[:no_empty_shifts][:sanction]},#{result[:demand_fulfill][:sanction]},#{result[:specialized_preferred][:sanction]},#{result[:free_days][:sanction]}\n"
            end
          rescue => _
            open('g-data.csv', 'a') do |f|
              f << "#{i},#{priority[:no_empty_shifts] || 0},#{priority[:demand_fulfill] || 0},#{priority[:specialized_preferred] || 0},#{priority[:free_days] || 0},E,E,E,E\n"
              next
            end
          end
        end
      end
    end
  end

  def evaluate_solution(solution)
    templates = ShiftTemplate.joins(:scheduling_unit).where(scheduling_units: {scheduling_period_id: @period.id}).order("start_time")
    violations = Hash.new

    # exclude shifts with no priority
    violations[:no_empty_shifts] = Scheduling::NoEmptyShifts.get_violations_hash(templates.filter { |s| s.priority > 0 }, solution, 1)

    violations[:demand_fulfill] = Scheduling::DemandFulfill.get_violations_hash(templates.filter { |s| s.priority > 0 }, solution, 1)

    violations[:specialized_preferred] = Scheduling::SpecializedPreferred.get_violations_hash(templates.filter { |s| s.priority > 0 }, solution, 1)

    violations[:free_days] = Scheduling::FreeDaysInRow.get_violations_hash(templates, solution, @period, 1)
    violations
  end
end