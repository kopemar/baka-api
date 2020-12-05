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
    e5 = employee_two_inactive_contracts

    employees = Employee.with_employment_contract

    assert employees.length == 3

    assert_not_nil employees.find_by(id: e1.id)
    assert_not_nil employees.find_by(id: e2.id)
    assert_nil employees.find_by(id: e3.id)
    assert_not_nil employees.find_by(id: e4.id)
    assert_nil employees.find_by(id: e5.id)
  end

end
