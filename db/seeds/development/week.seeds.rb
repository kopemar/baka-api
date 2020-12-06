FactoryBot.define do

  factory :demand do
    sequence(:start_time, 1) { |n| FFaker::Time.between((n*8).hours.since(Date.today), ((n+1)*8).hours.since(Date.today)) }
    sequence(:end_time, 1) { |n| FFaker::Time.between(start_time, ((n+1)*8).hours.since(Date.today)) }
    demand { rand(0..5) }
    specialization { 0 }
  end

end

FactoryBot.create_list(:demand, 5)
