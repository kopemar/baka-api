require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  test "Test schedules planned between" do
    create_shifts_happening_now

    assert_not_empty Schedule.planned_between(30.minutes.ago, 1.hour.from_now)
    assert_not_empty Schedule.planned_between(8.hours.ago, 8.hour.from_now)
    assert_empty Schedule.planned_between(1.week.from_now, 2.weeks.from_now)
  end
end
