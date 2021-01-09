FactoryBot.define do
  factory :scheduling_period do
    sequence(:start_date, 1) {  |n| n.weeks.from_now.monday.to_date }
    sequence(:end_date, 1) {  |n| n.weeks.from_now.sunday.to_date }
  end
end

FactoryBot.create_list(:scheduling_period, 4)
