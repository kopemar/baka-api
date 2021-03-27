require 'test_helper'

class SpecializationSchedulingTest < ActionDispatch::IntegrationTest
  def setup
    @org = generate_organization
    @manager = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(@manager)
  end

  test "Assign specialized shifts" do
    specialization = Specialization.create(name: "Clown", organization_id: @org.id)

    5.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(specialization)
      e.save!
    end

    period = FactoryBot.create(:scheduling_period, organization: @org)

    templates = generate_shift_templates(period, @auth_tokens)

    assert_equal 5, templates.length

    templates.each do |template|
      post "/templates/#{template[:id]}/specialized?specialization_id=#{specialization.id}",
           headers: @auth_tokens

      this_template = ShiftTemplate.where(id: template[:id]).first
      this_template.priority = 0
      this_template.save!
    end

    Scheduling::Scheduling.new({ id: period.id }).call

    # all specialized shifts must be assigned in this context
    assert ShiftTemplate::in_scheduling_period(period.id).joins(:specialization).none? { |s| s.shifts.empty? }
  end

end
