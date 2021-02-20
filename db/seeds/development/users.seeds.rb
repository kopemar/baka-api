after 'development:organizations' do
  first_index = Employee.count
  FactoryBot.define do
    factory :employee, class: Employee do
      first_name { FFaker::Name.first_name }
      last_name { FFaker::Name.last_name }
      sequence(:username, 1) { |n| "employee#{n + first_index}" }
      email { "#{username}@example.com" }
      password { "12345678" }
      birth_date { FFaker::Time.between(65.years.ago, 15.years.ago) }

      trait :adult do
        birth_date { FFaker::Time.between(65.years.ago, 18.years.ago) }
      end

      trait :underage do
        birth_date { FFaker::Time.between(18.years.ago, 15.years.ago) }
      end
    end
  end

  # FactoryBot.create_list(:employee, 50) do |employee|
  #   employee.organization = Organization.order(Arel.sql("RANDOM()")).first
  #   FactoryBot.create(:employment_contract) do |contract|
  #     contract.employee = employee
  #     contract.schedule_id = Schedule.create(contract_id: contract.id).id
  #     contract.save!
  #   end
  #   employee.save!
  # end
end