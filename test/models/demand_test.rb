require 'test_helper'

class DemandTest < ActiveSupport::TestCase
  test "Demand year test" do
    d1 = demand_this_year
    d2 = demand_not_this_year
    assert d1.year == Date.today.year
    assert d2.year != Date.today.year

    assert_not_nil Demand.in_year(Date.today.year).find_by(id: d1.id)
    assert_nil Demand.in_year(Date.today.year).find_by(id: d2.id)
  end

  test "Demand week test" do
    d1 = demand_this_week
    d2 = demand_not_this_week
    assert_equal(d1.week, Date.today.cweek)
    assert_not_equal(d2.week, Date.today.cweek)
  end
end
