FactoryBot.define do
  factory :shift_template do
    start_time { FFaker::Time.between(Date.today, 2.week.from_now).beginning_of_hour }
    end_time { rand(1..10).hours.after(start_time) }
  end
end

FactoryBot.create_list(:shift_template, 100)