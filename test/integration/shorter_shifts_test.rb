require 'test_helper'

class ShorterShiftsTest < ActionDispatch::IntegrationTest
  def setup
    @org = generate_organization
    @manager = FactoryBot.create(:manager, org: @org)
    @auth_tokens = auth_tokens_for_user(@manager)
    @period = FactoryBot.create(:scheduling_period, org: @org)
  end

  test "Plan shorter shifts" do

    e = employee_active_contract(@org)

    generate_long_shift_templates(@period, @auth_tokens)

    Scheduling::Scheduling.new({ id: @period.id }).call

    schedule = Schedule.joins(:contract).where(contracts: { employee_id: e.id }).first.shifts

    assert_equal 4, schedule.length
    assert_not schedule.all? { |s| s.duration == 12 }
    assert_equal 3, schedule.filter { |s| s.duration == 12 }.length
    Rails.logger.debug "🍼 #{schedule.map(&:duration)}"
    assert schedule.one? { |s| s.duration == 4 }
  end
end