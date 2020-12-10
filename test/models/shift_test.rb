require 'test_helper'

class ShiftTest < ActiveSupport::TestCase
  test "Shifts in time" do
    create_shifts_happening_now

    assert_not_empty Shift.planned_between(10.hour.ago, 10.hour.from_now)
    assert_not_empty Shift.planned_between(1.hour.ago, 1.hour.from_now)
    assert_empty Shift.planned_between(1.weeks.from_now, 2.weeks.from_now)
  end

end
