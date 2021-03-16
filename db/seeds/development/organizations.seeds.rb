FactoryBot.define do
  factory :organization do
    name { FFaker::Company.name }
  end
end

if Organization.count == 0
  FactoryBot.create_list(:organization, 4)
end