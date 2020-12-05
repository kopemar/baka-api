FactoryBot.define do

  factory :demand do
    start_time { FFaker::Time.between(Date.now, Date.tomorrow.midnight.to_datetime) }
    end_time { FFaker::Time.between(start_time, 2.days.since(start_time).midnight.to_datetime) }
    demand { rand(1..5) }
    specialization { 0 }
  end

end


