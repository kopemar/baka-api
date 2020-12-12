require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  test "Test schedules planned between" do
    create_shifts_happening_now

    assert_not_empty Schedule.planned_between(30.minutes.ago, 1.hour.from_now)
    assert_not_empty Schedule.planned_between(8.hours.ago, 8.hour.from_now)
    assert_empty Schedule.planned_between(1.week.from_now, 2.weeks.from_now)
  end

  test "Test schedules planned not now" do
    create_shifts_past_future

    assert_empty Schedule.planned_between(6.days.ago, 4.days.ago)
    assert_not_empty Schedule.planned_between(4.days.ago, 3.days.ago)
    assert_not_empty Schedule.planned_between(4.days.ago, 2.days.ago)
    assert_empty Schedule.planned_between(1.hours.ago, 8.hour.from_now)
    assert_not_empty Schedule.planned_between(3.days.from_now, 4.days.from_now)
  end
end
