require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  test "employee initialization" do
    assert_raise(ActiveRecord::RecordInvalid) {Employee.create!}
  end
  # test "the truth" do
  #   assert true
  # end
end
