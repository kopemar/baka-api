after 'development:organizations' do
  FactoryBot.define do
    factory :man, class: Manager do
      first_name { FFaker::Name.first_name }
      last_name { FFaker::Name.last_name }
      sequence(:username, 1) { |n| "manager#{n}" }
      email {  "#{username}@example.com" }
      password { "12345678" }
    end
  end

  FactoryBot.create_list(:man, 3) do |e|
    e.organization = Organization.order(Arel.sql("RANDOM()")).first
    e.save!
  end
end
