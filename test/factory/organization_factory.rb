FactoryBot.define do
  factory :organization_f, class: Organization do
    name { FFaker::Company.name }
  end
end

def generate_organization
  Organization.first_or_create(name: "Weber Electromechanics")
end
