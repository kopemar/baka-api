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

    specialization = Specialization.create(name: "Clown", organization_id: @org.id)

    templates.each do |template|
      post "/templates/#{template[:id]}/specialized?specialization_id=#{specialization.id}",
           headers: @auth_tokens

      this_template = ShiftTemplate.where(id: template[:id]).first
      this_template.priority = 0
      this_template.save!
    end

    # @to_schedule = period.scheduling_units.joins(:shift_templates)
    Scheduling::Scheduling.new({ id: period.id }).call
  end

end
