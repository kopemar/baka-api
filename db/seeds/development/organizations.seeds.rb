FactoryBot.define do
  factory :organization do
    name { FFaker::Company.name }
  end
end

if Organization.count == 0
  FactoryBot.create_list(:organization, 4) do |org|

    # FactoryBot.create_list(:employee, 20) do |employee|
    #   employee.organization = org
    #   FactoryBot.create(:employment_contract) do |contract|
    #     contract.employee = employee
    #     contract.schedule_id = Schedule.create(contract_id: contract.id).id
    #     contract.save!
    #   end
    #   employee.save!
    # end
    #
    # FactoryBot.create_list(:employee, 10) do |employee|
    #   employee.organization = org
    #   FactoryBot.create(:agreement_to_complete_a_job, :valid) do |contract|
    #     contract.employee = employee
    #     contract.schedule_id = Schedule.create(contract_id: contract.id).id
    #     contract.save!
    #   end
    #   employee.save!
    # end
    #
    # FactoryBot.create_list(:employee, 10) do |employee|
    #   employee.organization = org
    #   FactoryBot.create(:agreement_to_perform_a_job, :valid) do |contract|
    #     contract.employee = employee
    #     contract.schedule_id = Schedule.create(contract_id: contract.id).id
    #     contract.save!
    #   end
    #   employee.save!
    # end
  end
end