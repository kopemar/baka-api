FactoryBot.define do
  factory :shift do
    start_time { 1.hours.ago }
    end_time { 8.hours.from_now }

    trait :past do
      start_time { 3.days.ago }
      end_time { 8.hours.after(start_time) }
    end

    trait :future do
      start_time { 3.days.from_now }
      end_time { 8.hours.after(start_time) }
    end
  end
end

def create_shifts_happening_now
  FactoryBot.create_list(:employee, 5) do |e|
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        FactoryBot.create(:shift, schedule: s)
        c.schedule_id = s.id
        c.save!
      end
    end
  end

  FactoryBot.create_list(:employee, 2) do |e|
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save!
      end
    end
  end
end

def create_shifts_past_future
  FactoryBot.create_list(:employee, 5) do |e|
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        FactoryBot.create(:shift, :past, schedule: s)
        FactoryBot.create(:shift, :future, schedule: s)
        c.schedule_id = s.id
        c.save!
      end
    end
  end

  FactoryBot.create_list(:employee, 2) do |e|
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        FactoryBot.create(:shift, :past, schedule: s)
        c.schedule_id = s.id
        c.save!
      end
    end
  end
end