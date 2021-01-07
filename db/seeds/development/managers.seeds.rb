FactoryBot.define do
  factory :man, class: Manager do
    sequence(:username, 1) { |n| "manager#{n}" }
    email {  "#{username}@example.com" }
    password { "12345678" }
  end
end

FactoryBot.create_list(:man, 3)
