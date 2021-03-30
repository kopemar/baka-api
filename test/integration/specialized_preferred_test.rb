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

  test "Specialized Preferred Improve" do
    s1 = Specialization.create(name: "Clown", organization_id: @org.id)
    s2 = Specialization.create(name: "Cook", organization_id: @org.id)
    s3 = Specialization.create(name: "Waiter", organization_id: @org.id)
    period = FactoryBot.create(:scheduling_period, organization: @org)
    templates = generate_shift_templates(period, @auth_tokens)

    3.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    4.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s2)
      e.contracts.first.specializations.push(s3)
      e.save!
    end

    4.times do
      employee_active_contract(@org)
    end

    original_templates = ShiftTemplate::in_scheduling_period(period.id).to_a
    original_templates.sample(3).each do |template|
      post "/templates/#{template[:id]}/specialized?specialization_id=#{s1.id}",
           headers: @auth_tokens
    end

    original_templates.sample(3).each do |template|
      post "/templates/#{template[:id]}/specialized?specialization_id=#{s2.id}",
           headers: @auth_tokens
    end

    original_templates.sample(3).each do |template|
      post "/templates/#{template[:id]}/specialized?specialization_id=#{s3.id}",
           headers: @auth_tokens
    end

    Scheduling::Scheduling.new({ id: period.id, priorities: {}}).call

    schedule = {}
    Shift.where(shift_template: ShiftTemplate::in_scheduling_period(period.id)).to_a.group_by { |shift|
      shift.schedule_id
    }.each { |k, v|
      schedule[k] = v.map(&:shift_template_id)
    }

    violations_hash_1 = Scheduling::SpecializedPreferred.get_violation_hash(ShiftTemplate::in_scheduling_period(period.id), schedule)
    Rails.logger.debug "😑 schedule: #{schedule} #{violations_hash_1}"

    initial_sanction = violations_hash_1[:sanction]

    Scheduling::Scheduling.new({ id: period.id, priorities: { :specialized_preferred => 10 }}).call
    schedule = {}
    Shift.where(shift_template: ShiftTemplate::in_scheduling_period(period.id)).to_a.group_by { |shift|
      shift.schedule_id
    }.each { |k, v|
      schedule[k] = v.map(&:shift_template_id)
    }

    violations_hash_2 = Scheduling::SpecializedPreferred.get_violation_hash(ShiftTemplate::in_scheduling_period(period.id), schedule)
    Rails.logger.debug "😑 schedule: #{schedule} #{violations_hash_2}"

    new_sanction = violations_hash_2[:sanction]

    Rails.logger.debug "🐻‍❄️ SANCTION #{initial_sanction} / #{new_sanction}"
    # can fail
    assert initial_sanction > new_sanction
  end

end