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

  FactoryBot.create_list(:employment_contract, 10) do |c|
    c.employee = Employee.order(Arel.sql("RANDOM()")).first
    c.schedule = Schedule.create
    c.save!
  end
end
