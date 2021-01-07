FactoryBot.define do
  factory :organization do
    name { FFaker::Company.name }
  end
end

FactoryBot.create_list(:organization, 4)