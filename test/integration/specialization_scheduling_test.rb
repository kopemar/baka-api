require 'test_helper'

class SpecializationSchedulingTest < ActionDispatch::IntegrationTest
  def setup
    @org = generate_organization
    @manager = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(@manager)
  end

  test "Assign specialized shifts" do
    5.times do
      employee_active_contract(@org)
    end

    period = FactoryBot.create(:scheduling_period, organization: @org)

    templates = generate_shift_templates(period, @auth_tokens)

    assert_equal 5, templates.length

  end

end
