require 'test_helper'

class ContractTest < ActiveSupport::TestCase
  test "Contracts with active shifts" do
    c1 = schedule_shift_now
    c2 = schedule_shift_past

    schedule1 = Schedule.where(id: c1.schedule_id).first
    assert_not_nil schedule1

    schedule2 = Schedule.where(id: c2.schedule_id).first
    p c2.schedule_id
    assert_not_nil schedule2

    s1 = Shift.where(schedule_id: schedule1.id).first
    s2 = Shift.where(schedule_id: schedule2.id).first

    assert_not_nil s1
    assert_not_nil s2

    assert_not_nil Shift.planned_between(8.hours.ago, 8.hours.from_now).find_by(id: s1.id)
    assert_nil Shift.planned_between(8.hours.ago, 8.hours.from_now).find_by(id: s2.id)

    assert_not_nil Contract.shifts_planned(8.hours.ago, 8.hours.from_now).find_by(id: c1.id)
    assert_nil Contract.shifts_planned(8.hours.ago, 8.hours.from_now).find_by(id: c2.id)
  end

  test "Agreement Hours" do
    # employee doesn't matter if not necessary
    contract = AgreementToCompleteAJob.create

    shift = Shift.from_template(get_shift_now)
    shift.schedule_id = contract.schedule_id
    shift.save!

    shift2 = Shift.from_template(get_shift_2019)
    shift2.schedule_id = contract.schedule_id
    shift2.save!

    assert_equal 8, contract.hours_per_year(shift.start_time.year)
  end
end
