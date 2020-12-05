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

end
