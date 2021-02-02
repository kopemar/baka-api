require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase

  test "employee initialization" do
    o = generate_organization
    e = FactoryBot.create(
        :employee,
        organization_id: o.id
    )
    assert(e.id != nil)
  end

  test "Employee with one active contract" do
    employee = employee_with_contracts

    assert employee.contracts.length == 2
  end

  test "Employee with two active contract" do
    employee = employee_two_active_contracts

    assert employee.contracts.length == 2
  end

  test "Get employees with active employment contracts" do
    e1 = employee_two_active_contracts
    e2 = employee_with_contracts
    e3 = employee_with_no_contract
    e4 = employee_two_active_contracts

    employees = Employee.with_employment_contract

    assert employees.length == 3
    p Employee.with_employment_contract

    assert_not_nil employees.find_by(username: e1.username)
    assert_not_nil employees.find_by(username: e2.username)
    assert_nil employees.find_by(username: e3.username)
    assert_not_nil employees.find_by(username: e4.username)
  end

  test "Can work at?" do
    e1 = employee_monday
    monday = Date.today.monday.to_date
    tuesday = 1.day.after(monday)

    assert e1.can_work_at?(monday)
    assert_not e1.can_work_at?(tuesday)
  end

  test "Last shift test" do
    e1 = create_employee_shifts_past
    assert_not_nil e1.get_last_scheduled_shift_before(Date.today.midnight)
    assert_equal("2019-12-30".to_datetime, e1.get_last_scheduled_shift_before(Date.today.midnight).start_time)
  end
end
