FactoryBot.define do
  factory :shift do
    start_time { FFaker::Time.between(Date.today, 2.week.from_now) }
    end_time { rand(1..10).hours.after(start_time) }
  end
end

FactoryBot.create_list(:shift, 100)