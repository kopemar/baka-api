require 'test_helper'

class SpecializationSchedulingTest < ActionDispatch::IntegrationTest
  def setup
    @org = generate_organization
    @manager = FactoryBot.create(:manager, org: @org)
    @auth_tokens = auth_tokens_for_user(@manager)
    @period = FactoryBot.create(:scheduling_period, org: @org)
  end

  # test "20 Empty Shifts Fix the solution" do
  #   20.times do
  #     employee_active_contract(@org)
  #   end
  #
  #   generate_more_shift_templates(@period, @auth_tokens)
  #
  #   Scheduling::Scheduling.new({ id: @period.id, priorities: {} }).call
  #
  #   schedule = get_period_as_schedule(@period)
  #   initial_violations = Scheduling::NoEmptyShifts.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule)
  #   initial_sanction = initial_violations[:sanction]
  #
  #   Scheduling::Scheduling.new({ id: @period.id, priorities: { :no_empty_shifts => 10} }).call
  #
  #   schedule = get_period_as_schedule(@period)
  #   violations = Scheduling::NoEmptyShifts.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule)
  #   sanction = violations[:sanction]
  #   Rails.logger.debug "INITIAL: #{initial_sanction}, SANCTION: #{sanction}"
  #   assert initial_sanction > sanction || sanction == 0
  # end

  # test "5 E Empty Shifts Fix the solution" do
  #   5.times do
  #     employee_active_contract(@org)
  #   end
  #
  #   generate_more_shift_templates(@period, @auth_tokens)
  #
  #   Scheduling::Scheduling.new({ id: @period.id, priorities: {} }).call
  #
  #   schedule = get_period_as_schedule(@period)
  #   initial_violations = Scheduling::NoEmptyShifts.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule)
  #   initial_sanction = initial_violations[:sanction]
  #
  #   Scheduling::Scheduling.new({ id: @period.id, priorities: { :no_empty_shifts => 10} }).call
  #
  #   schedule = get_period_as_schedule(@period)
  #   violations = Scheduling::NoEmptyShifts.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule)
  #   sanction = violations[:sanction]
  #   Rails.logger.debug "INITIAL: #{initial_sanction}, SANCTION: #{sanction}"
  #   assert initial_sanction > sanction || sanction == 0
  # end
  #
  #
  test "10A E No Empty Shifts Fix the solution with specialization" do
    s1 = Specialization.create(name: "Clown", organization_id: @org.id)

    10.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.save!
    end

    templates = generate_more_shift_templates(@period, @auth_tokens)

    templates.each do |template|
      post "/api/v1/templates/#{template[:id]}/specialized?specialization_id=#{s1.id}",
           headers: @auth_tokens

      ShiftTemplate.find(template[:id]).update(priority: 0)
    end

    Scheduling::Scheduling.new({ id: @period.id, priorities: {} }).call

    schedule = get_period_as_schedule(@period)
    initial_violations = Scheduling::NoEmptyShifts.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule)
    initial_sanction = initial_violations[:sanction]

    Scheduling::Scheduling.new({ id: @period.id, priorities: { :specialized_preferred => 10, :no_empty_shifts => 10} }).call

    schedule = get_period_as_schedule(@period)
    violations = Scheduling::SpecializedPreferred.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule)
    sanction = violations[:sanction]
    Rails.logger.debug "INITIAL: #{initial_sanction}, SANCTION: #{sanction}"
    assert initial_sanction > sanction || sanction == 0
  end

  test "10B Empty Shifts Fix the solution with specialization" do
    s1 = Specialization.create(name: "Clown", organization_id: @org.id)

    10.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.save!
    end

    # 10.times do
    #   employee_active_contract(@org)
    # end

    templates = generate_more_shift_templates(@period, @auth_tokens)

    templates.sample(10).each do |template|
          post "/api/v1/templates/#{template[:id]}/specialized?specialization_id=#{s1.id}",
               headers: @auth_tokens
          # ShiftTemplate.find(template[:id]).update(priority: 0)
        end

    Scheduling::Scheduling.new({ id: @period.id, priorities: {} }).call

    schedule = get_period_as_schedule(@period)
    initial_violations = Scheduling::NoEmptyShifts.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule)
    initial_sanction = initial_violations[:sanction]

    Scheduling::Scheduling.new({ id: @period.id, priorities: { :no_empty_shifts => 10 } }).call

    schedule = get_period_as_schedule(@period)
    violations = Scheduling::NoEmptyShifts.get_violations_hash(ShiftTemplate::in_scheduling_period(@period.id), schedule)
    sanction = violations[:sanction]
    Rails.logger.debug "INITIAL: #{initial_sanction}, SANCTION: #{sanction}"
    assert initial_sanction > sanction || sanction == 0
  end

  # test "Assign specialized shifts" do
  #   specialization = Specialization.create(name: "Clown", organization_id: @org.id)
  #
  #   5.times do
  #     e = employee_active_contract(@org)
  #     e.contracts.first.specializations.push(specialization)
  #     e.save!
  #   end
  #
  #   templates = generate_shift_templates(@period, @auth_tokens)
  #
  #   assert_equal 5, templates.length
  #
  #   templates.each do |template|
  #     post "/api/v1/templates/#{template[:id]}/specialized?specialization_id=#{specialization.id}",
  #          headers: @auth_tokens
  #
  #     this_template = ShiftTemplate.where(id: template[:id]).first
  #     this_template.priority = 0
  #     this_template.save!
  #   end
  #
  #   Scheduling::Scheduling.new({ id: @period.id }).call
  #
  #   # all specialized shifts must be assigned in this context
  #   assert ShiftTemplate::in_scheduling_period(@period.id).joins(:specialization).none? { |s| s.shifts.empty? }
  # end
  #
  # test "Assign specialized shifts 2 - more complex" do
  #   s1 = Specialization.create(name: "Clown", organization_id: @org.id)
  #   s2 = Specialization.create(name: "Cook", organization_id: @org.id)
  #
  #   3.times do
  #     e = employee_active_contract(@org)
  #     e.contracts.first.specializations.push(s1)
  #     e.save!
  #   end
  #
  #   3.times do
  #     e = employee_active_contract(@org)
  #     e.contracts.first.specializations.push(s2)
  #     e.save!
  #   end
  #
  #   templates = generate_shift_templates(@period, @auth_tokens)
  #
  #   assert_equal 5, templates.length
  #
  #   templates.each do |template|
  #     post "/api/v1/templates/#{template[:id]}/specialized?specialization_id=#{s1.id}",
  #          headers: @auth_tokens
  #
  #     post "/api/v1/templates/#{template[:id]}/specialized?specialization_id=#{s2.id}",
  #          headers: @auth_tokens
  #
  #     this_template = ShiftTemplate.where(id: template[:id]).first
  #     this_template.update(priority: 0)
  #   end
  #
  #   Scheduling::Scheduling.new({ id: @period.id }).call
  #
  #   # all specialized shifts must be assigned in this context
  #   assert ShiftTemplate::in_scheduling_period(@period.id).joins(:specialization).none? { |s| s.shifts.empty? }
  #
  #   assert ShiftTemplate::in_scheduling_period(@period.id).where(specialization_id: nil).all? { |s| s.shifts.empty? }
  #
  #   assert ShiftTemplate::in_scheduling_period(@period.id).where(specialization_id: s1.id).all? { |s| s.shifts.length == 3 }
  # end
  #
  #
  # test "Assign specialized shifts 3 - employees with multiple specializations" do
  #   s1 = Specialization.create(name: "Clown", organization_id: @org.id)
  #   s2 = Specialization.create(name: "Cook", organization_id: @org.id)
  #
  #   # e1 = employee_active_contract(@org)
  #   # e1.contracts.first.specializations.push(s1)
  #   # e1.save!
  #
  #   employees = { s1.id => [], s2.id => [], :both => [] }
  #
  #   3.times do
  #     e = employee_active_contract(@org)
  #     e.contracts.first.specializations.push(s1)
  #     e.save!
  #     employees[s1.id].push(e)
  #   end
  #
  #   3.times do
  #     e = employee_active_contract(@org)
  #     e.contracts.first.specializations.push(s2)
  #     e.save!
  #     employees[s2.id].push(e)
  #   end
  #
  #   3.times do
  #     e = employee_active_contract(@org)
  #     e.contracts.first.specializations.push(s1)
  #     e.contracts.first.specializations.push(s2)
  #     e.save!
  #     employees[:both].push(e)
  #   end
  #
  #   period = FactoryBot.create(:scheduling_period, organization: @org)
  #
  #   templates = generate_shift_templates(period, @auth_tokens)
  #
  #   assert_equal 5, templates.length
  #
  #   templates.each do |template|
  #     post "/api/v1/templates/#{template[:id]}/specialized?specialization_id=#{s1.id}",
  #          headers: @auth_tokens
  #
  #     post "/api/v1/templates/#{template[:id]}/specialized?specialization_id=#{s2.id}",
  #          headers: @auth_tokens
  #
  #     this_template = ShiftTemplate.where(id: template[:id]).first
  #     this_template.update(priority: 0)
  #   end
  #
  #   Scheduling::Scheduling.new({ id: period.id }).call
  #
  #   # all specialized shifts must be assigned in this context
  #   assert ShiftTemplate::in_scheduling_period(period.id).joins(:specialization).none? { |s| s.shifts.empty? }
  #
  #   assert ShiftTemplate::in_scheduling_period(period.id).where(specialization_id: nil).all? { |s| s.shifts.empty? }
  #
  #   assert ShiftTemplate::in_scheduling_period(period.id).where(specialization_id: s1.id).all? { |s| s.shifts.length >= 3 }
  #   assert ShiftTemplate::in_scheduling_period(period.id).where(specialization_id: s2.id).all? { |s| s.shifts.length >= 3 }
  #
  #   employees[s1.id].each do |employee|
  #     shifts =  Employee.find(employee.id).contracts.first.schedule.shifts
  #
  #     assert_equal 5, shifts.length
  #     assert shifts.all? { |s| s.shift_template.specialization_id == s1.id }
  #   end
  #
  #   employees[s2.id].each do |employee|
  #     shifts =  Employee.find(employee.id).contracts.first.schedule.shifts
  #
  #     assert_equal 5, shifts.length
  #     assert shifts.all? { |s| s.shift_template.specialization_id == s2.id }
  #   end
  #
  #   employees[:both].each do |employee|
  #     shifts =  Employee.find(employee.id).contracts.first.schedule.shifts
  #
  #     assert_equal 5, shifts.length
  #     assert shifts.all? { |s| s.shift_template.specialization_id == s2.id || s.shift_template.specialization_id == s1.id }
  #   end
  # end
  #
  # test "Greater Organization with multiple specializations" do
  #   s1 = Specialization.create(name: "Clown", organization_id: @org.id)
  #   s2 = Specialization.create(name: "Cook", organization_id: @org.id)
  #   s3 = Specialization.create(name: "Waiter", organization_id: @org.id)
  #   s4 = Specialization.create(name: "Bartender", organization_id: @org.id)
  #   s5 = Specialization.create(name: "Barista", organization_id: @org.id)
  #
  #   specializations = [s1, s2, s3, s4, s5]
  #
  #   3.times do
  #     e = employee_active_contract(@org)
  #     e.contracts.first.specializations.push(s1)
  #     e.contracts.first.specializations.push(s2)
  #     e.save!
  #   end
  #
  #   4.times do
  #     e = employee_active_contract(@org)
  #     e.contracts.first.specializations.push(s2)
  #     e.contracts.first.specializations.push(s3)
  #     e.save!
  #   end
  #
  #   6.times do
  #     e = employee_active_contract(@org)
  #     e.contracts.first.specializations.push(s4)
  #     e.save!
  #   end
  #
  #   2.times do
  #     e = employee_active_contract(@org)
  #     e.contracts.first.specializations.push(s1)
  #     e.contracts.first.specializations.push(s2)
  #     e.contracts.first.specializations.push(s5)
  #     e.save!
  #   end
  #
  #   8.times do
  #     employee_active_contract(@org)
  #   end
  #
  #   period = FactoryBot.create(:scheduling_period, organization: @org)
  #
  #   templates = generate_more_shift_templates(period, @auth_tokens)
  #
  #   12.times do
  #     template = templates.sample
  #
  #     post "/api/v1/templates/#{template[:id]}/specialized?specialization_id=#{specializations.sample.id}",
  #          headers: @auth_tokens
  #   end
  #
  #   Scheduling::Scheduling.new({ id: period.id }).call
  # end
end
