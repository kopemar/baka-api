after 'development:organizations' do
  FactoryBot.define do
    factory :scheduling_period do
      sequence(:start_date, 1) { |n| n.weeks.from_now.monday.to_date }
      sequence(:end_date, 1) { |n| n.weeks.from_now.sunday.to_date }

      trait :one_week do
        start_date { 1.weeks.from_now.monday.to_date }
        end_date { 1.weeks.from_now.sunday.to_date }
      end

      trait :two_weeks do
        start_date { 2.weeks.from_now.monday.to_date }
        end_date { 2.weeks.from_now.sunday.to_date }
      end

      trait :three_weeks do
        start_date { 3.weeks.from_now.monday.to_date }
        end_date { 3.weeks.from_now.sunday.to_date }
      end

    end
  end

  Organization.all.each do |o|
    FactoryBot.build(:scheduling_period, :one_week) do |w|
      w.organization_id = o.id
      w.save
    end

    FactoryBot.build(:scheduling_period, :two_weeks) do |w|
      w.organization_id = o.id
      w.save
    end

    FactoryBot.build(:scheduling_period, :three_weeks) do |w|
      w.organization_id = o.id
      w.save
    end
  end
end