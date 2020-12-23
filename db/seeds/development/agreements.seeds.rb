# after 'development:users' do
  FactoryBot.define do
    factory :agreement_to_complete_a_job do
      start_date { FFaker::Time.between(1.years.from_now, 7.months.ago) }
      end_date { FFaker::Time.between(6.months.ago, 3.years.from_now) }
    end
  end

  FactoryBot.create_list(:agreement_to_complete_a_job, 10) do |c|
    c.employee = Employee.order(Arel.sql("RANDOM()")).first
    c.schedule_id = Schedule.create(contract_id: c.id).id
    c.save!
  end
# end
