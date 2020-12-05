require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase

  test "employee initialization" do
    e = Employee.create!(username: "employee", email:"employee@example.com", first_name: FFaker::Name.first_name, last_name: FFaker::Name.last_name, birth_date: "2000-12-24")
    assert(e.id != nil)
  end

  # test "the truth" do
  #   assert true
  # end
end
