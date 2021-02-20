after 'development:users' do
  FactoryBot.define do
    factory :employment_contract do
      start_date { FFaker::Time.between(15.years.ago, 1.years.from_now) }
      end_date { FFaker::Time.between(1.years.ago, 3.years.from_now) }
      work_load { 1.0 }
      working_days { [1, 2, 3, 4, 5] }

      trait :indefinite do
        end_date { nil }
      end
    end
  end

  Organization.all.each { |org|
    FactoryBot.create_list(:employee, 20) do |employee|
      employee.organization = org
      FactoryBot.create(:employment_contract) do |contract|
        contract.employee = employee
        contract.schedule_id = Schedule.create(contract_id: contract.id).id
        contract.save!
      end
      employee.save!
    end
  }

end
