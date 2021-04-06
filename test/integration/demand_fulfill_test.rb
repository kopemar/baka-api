require 'test_helper'

class DemandFulfillTest < ActionDispatch::IntegrationTest
  def setup
    @org = generate_organization
    @manager = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(@manager)
    @period = FactoryBot.create(:scheduling_period, organization: @org)
  end

  test "A Demand Fulfill Fix the solution?" do
    s1 = Specialization.create(name: "Clown", organization_id: @org.id)

    10.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.save!
    end

    # 10.times do
    #   employee_active_contract(@org)
    # end

    generate_more_shift_templates(@period, @auth_tokens)

    templates = ShiftTemplate::in_scheduling_period(@period.id).to_a

    templates.sample(5).each do |t|
      template = ShiftTemplate.find(t.id)
      template.priority = 1
      template.save!
    end

    templates.filter { |t| t.priority == 2 }.sample(5).each do |t|
      template = ShiftTemplate.find(t.id)
      template.priority = 3
      template.save!
    end

    templates.filter { |t| t.priority == 2 }.sample(5).each do |t|
      template = ShiftTemplate.find(t.id)
      template.priority = 4
      template.save!
    end

    templates.filter { |t| t.priority == 2 }.sample(5).each do |t|
      template = ShiftTemplate.find(t.id)
      template.priority = 5
      template.save!
    end

    Scheduling::Scheduling.new({ id: @period.id, priorities: {} }).call

    schedule = get_period_as_schedule(@period)
    initial_violations = Scheduling::FreeDaysInRow.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule, @period)
    initial_sanction = initial_violations[:sanction]

    Scheduling::Scheduling.new({ id: @period.id, priorities: { :demand_fulfill => 10 } }).call

    schedule = get_period_as_schedule(@period)
    violations = Scheduling::FreeDaysInRow.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule, @period)
    sanction = violations[:sanction]
    Rails.logger.debug "INITIAL: #{initial_sanction}, SANCTION: #{sanction}"
    assert initial_sanction > sanction || sanction == 0
  end

end
