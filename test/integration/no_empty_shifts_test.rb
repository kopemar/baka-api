require 'test_helper'

class NoEmptyShiftsTest < ActionDispatch::IntegrationTest

  def setup
    @org = generate_organization
    @manager = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(@manager)

    @period = FactoryBot.create(:scheduling_period, organization: @org)
  end

  test "1A-NoEmptyShifts" do
    20.times do
      employee_active_contract(@org)
    end

    generate_more_shift_templates(@period, @auth_tokens)

    Scheduling::Scheduling.new({ id: @period.id, priorities: {} }).call

    schedule = get_period_as_schedule(@period)
    initial_violations = Scheduling::SpecializedPreferred.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule)
    initial_sanction = initial_violations[:sanction]

    Scheduling::Scheduling.new({ id: @period.id, priorities: { :no_empty_shifts => 10} }).call

    schedule = get_period_as_schedule(@period)
    violations = Scheduling::SpecializedPreferred.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule)
    sanction = violations[:sanction]
    Rails.logger.debug "INITIAL: #{initial_sanction}, SANCTION: #{sanction}"
    assert initial_sanction > sanction || sanction == 0
  end

  test "1B-NoEmptyShifts" do
    20.times do
      employee_active_contract(@org)
    end

    generate_more_shift_templates(@period, @auth_tokens)

    Scheduling::Scheduling.new({ id: @period.id, priorities: {} }).call

    schedule = get_period_as_schedule(@period)
    initial_violations = Scheduling::SpecializedPreferred.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule)
    initial_sanction = initial_violations[:sanction]

    Scheduling::Scheduling.new({ id: @period.id, priorities: { :no_empty_shifts => 10} }).call

    schedule = get_period_as_schedule(@period)
    violations = Scheduling::SpecializedPreferred.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule)
    sanction = violations[:sanction]
    Rails.logger.debug "INITIAL: #{initial_sanction}, SANCTION: #{sanction}"
    assert initial_sanction > sanction || sanction == 0
  end

end
