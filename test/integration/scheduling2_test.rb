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
    period = FactoryBot.create(:scheduling_period, org: org)
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
        organization_id: @org.id,
        is_employment_contract: parent_template.is_employment_contract,
        parent_template_id: parent_template.id,
        specialization_id: specialization.id
    )
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
