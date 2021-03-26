after 'development:users' do
  FactoryBot.define do
    factory :agreement_to_complete_a_job do
      start_date { FFaker::Time.between(1.years.ago, 7.months.ago) }
      end_date { FFaker::Time.between(6.months.after(start_date), 3.years.after(start_date)) }

      trait :valid do
        start_date { FFaker::Time.between(1.years.ago, 1.months.ago) }
        end_date { FFaker::Time.between(1.months.from_now, 3.years.from_now) }
      end
    end
  end

  FactoryBot.define do
    factory :agreement_to_perform_a_job do
      start_date { FFaker::Time.between(1.years.ago, 7.months.ago) }
      end_date { FFaker::Time.between(6.months.after(start_date), 3.years.after(start_date)) }

      trait :valid do
        start_date { FFaker::Time.between(1.years.ago, 1.months.ago) }
        end_date { FFaker::Time.between(1.months.from_now, 3.years.from_now) }
      end
    end
  end

  Organization.all.each { |org|
    FactoryBot.create_list(:employee, 10) do |employee|
      employee.organization = org
      FactoryBot.create(:agreement_to_complete_a_job, :valid, employee_id: employee.id)
        employee.save!
    end

    FactoryBot.create_list(:employee, 10) do |employee|
      employee.organization = org
      FactoryBot.create(:agreement_to_perform_a_job, :valid, employee_id: employee.id)
      employee.save!
    end
  }

end
