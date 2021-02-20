after 'development:organizations' do
  first_index = Manager.all.count || 0
  FactoryBot.define do
    factory :man, class: Manager do
      first_name { FFaker::Name.first_name }
      last_name { FFaker::Name.last_name }
      sequence(:username, 1) { |n| "manager#{n + first_index}" }
      email {  "#{username}@example.com" }
      password { "12345678" }
    end
  end

  Organization.all.each { |org|
    FactoryBot.create_list(:man, 3) do |e|
      e.organization = org
      e.save!
    end
  }

end
