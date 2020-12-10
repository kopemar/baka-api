require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase

  test "employee initialization" do
    e = Employee.create!(username: "employee", email:"employee@example.com", first_name: FFaker::Name.first_name, last_name: FFaker::Name.last_name, birth_date: "2000-12-24")
    assert(e.id != nil)
  end

  test "Employee with one active contract" do
    employee = employee_with_contracts

    assert employee.contracts.length == 2
    assert !employee.has_multiple_active_contracts?
  end

  test "Employee with two active contract" do
    employee = employee_two_active_contracts

    assert employee.contracts.length == 2
    assert employee.has_multiple_active_contracts?
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

  test "Get employees to plan" do
    e1 = employee_shift_now
    p "e1 #{e1}"
    assert Employee.to_be_planned(1.day.ago, 1.day.from_now).empty?

    e2 = employee_shift_past

    assert Employee.to_be_planned(1.day.ago, 1.day.from_now).length == 1

    assert_nil Employee.to_be_planned(1.day.ago, 1.day.from_now).find_by(username: e1.username)
    assert_not_nil Employee.to_be_planned(1.day.ago, 1.day.from_now).find_by(username: e2.username)
  end

end
