FactoryBot.define do
  factory :employee do
    type { "Employee" }
    first_name { "Alice"}
    last_name { "Mock" }
    sequence(:email, 1) { |n|
      "alice.mock#{n}@example.com"
    }
    sequence(:username, 1) { |n|
      "mock.alice#{n}"
    }
    birth_date { "2000-10-01" }
  end

  factory :contract, class: EmploymentContract do
    start_date { "2019-01-01" }
    employee
    work_load { 1.0 }
    working_days { [1] }

    trait :inactive do
      end_date { "2020-01-01" }
    end

    trait :active do
      end_date { nil }
    end

  end
end

def employee_with_contracts
  FactoryBot.create(:employee) do |e|
    FactoryBot.create(:contract, :inactive, employee: e)
    FactoryBot.create(:contract, :active, employee: e)
  end
end

def employee_two_active_contracts
  FactoryBot.create(:employee) do |e|
    FactoryBot.create_list(:contract, 2, :active, employee: e)
  end
end

def employee_two_inactive_contracts
  FactoryBot.create(:employee) do |e|
    FactoryBot.create_list(:contract, 2, :inactive, employee: e)
  end
end

def employee_with_no_contract
  FactoryBot.create(:employee)
end
