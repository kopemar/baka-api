require 'test_helper'

class SpecializedPreferredTest < ActionDispatch::IntegrationTest
  def setup
    @org = generate_organization
    @manager = FactoryBot.create(:manager, organization: @org)
    @auth_tokens = auth_tokens_for_user(@manager)
  end


  test "Specialized Preferred Violations" do

    s1 = Specialization.create(name: "s1", organization: @org)

    period = FactoryBot.create(:scheduling_period, organization: @org)

    templates = generate_shift_templates(period, @auth_tokens)

    original_templates = ShiftTemplate::in_scheduling_period(period.id).to_a
    original_templates.each do |template|
      post "/templates/#{template[:id]}/specialized?specialization_id=#{s1.id}",
           headers: @auth_tokens
    end

    schedule = {}
    template_ids = original_templates.map(&:id)

    12.times do |i|
      schedule[i] = template_ids
    end

    specialized_ids = ShiftTemplate::in_scheduling_period(period.id).where.not(specialization_id: nil).to_a.map(&:id)
    assert_not_empty specialized_ids

    5.times do |i|
      schedule[i + 12] = specialized_ids
    end

    assert_equal 600, Scheduling::SpecializedPreferred.get_violation_hash(ShiftTemplate::in_scheduling_period(period.id).to_a, schedule, 10)[:sanction]

  end

end
