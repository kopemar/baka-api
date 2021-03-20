require 'test_helper'

class SpecializationTest < ActiveSupport::TestCase
  test "Employee Specialization" do
    o = generate_organization
    s = Specialization.create(name: "Clown", organization_id: o.id)

    e1 = employee_active_contract(o)
    assert_empty e1.specializations

    specializations = e1.contracts.first.specializations
    specializations.push(s)
    e1.save!

    Rails.logger.debug e1.specializations

    assert_not_empty e1.specializations
    assert_equal s, e1.specializations.first

    assert_equal s, o.specializations.first

  end
end
