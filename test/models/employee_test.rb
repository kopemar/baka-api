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

  test "Employee with active contract" do
    employee = employee_active_contract

    assert_not_nil employee.contracts.first
    assert employee.contracts.length == 1
  end

  test "Get employees with active employment contracts" do
    e1 = employee_active_contract
    e2 = employee_with_contracts
    e3 = employee_with_no_contract
    e4 = employee_active_contract

    employees = Employee.with_employment_contract

    assert employees.length == 3
    p Employee.with_employment_contract

    assert_not_nil employees.find_by(username: e1.username)
    assert_not_nil employees.find_by(username: e2.username)
    assert_nil employees.find_by(username: e3.username)
    assert_not_nil employees.find_by(username: e4.username)
  end

end
