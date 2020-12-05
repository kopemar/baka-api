FactoryBot.define do

  factory :demand do
    start_time { FFaker::Time.between(Date.today, Date.tomorrow.midnight.to_datetime) }
    end_time { FFaker::Time.between(start_time, 2.days.since(start_time).midnight.to_datetime) }
    demand { rand(1..5) }
    specialization { 0 }

    trait :not_this_year do
      start_time { FFaker::Time.between(2.year.ago, 1.year.ago) }
    end

    trait :this_week do
      start_time { FFaker::Time.between(Date.today.monday, Date.today.midnight) }
      end_time { FFaker::Time.between(start_time, Date.today.sunday) }
    end

    trait :not_this_week do
      start_time { FFaker::Time.between(3.weeks.ago.monday, 3.weeks.ago.midnight) }
    end
  end

end

def demand_this_year
  FactoryBot.create(:demand)
end

def demand_not_this_year
  FactoryBot.create(:demand, :not_this_year)
end

def demand_this_week
  FactoryBot.create(:demand, :this_week)
end

def demand_not_this_week
  FactoryBot.create(:demand, :not_this_week)
end