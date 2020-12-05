FactoryBot.define do
  factory :employee, class: Employee do
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    sequence(:username, 1) { |n| "employee#{n}" }
    email {  "#{username}@example.com" }
    password { "12345678" }
    birth_date { FFaker::Time.between(65.years.ago, 15.years.ago) }

    trait :adult do
      birth_date { FFaker::Time.between(65.years.ago, 18.years.ago) }
    end

    trait :underage do
      birth_date { FFaker::Time.between(18.years.ago, 15.years.ago) }
    end
  end
end

FactoryBot.create_list(:employee, 10)