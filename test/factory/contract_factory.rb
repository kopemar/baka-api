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
    encrypted_password { "" }
    birth_date { "2000-10-01" }
  end

  factory :contract, class: EmploymentContract do
    start_date { "2019-01-01" }
    employee
    work_load { 1.0 }
    working_days { [1, 2, 3] }

    trait :inactive do
      end_date { "2020-01-01" }
    end

    trait :active do
      end_date { nil }
    end

    trait :works_mondays do
      working_days { [1] }
    end
  end


end

def employee_with_contracts
  FactoryBot.create(:employee) do |e|
    FactoryBot.create(:contract, :inactive, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save
      end
    end
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save
      end
    end
  end
end

def employee_two_active_contracts
  FactoryBot.create(:employee) do |e|
    FactoryBot.create_list(:contract, 2, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save
      end
    end
  end
end

def employee_inactive_contracts
  FactoryBot.create(:employee) do |e|
    FactoryBot.create_list(:contract, 2, :inactive, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save
      end
    end
  end
end

def employee_with_no_contract
  FactoryBot.create(:employee)
end

def employee_monday
  FactoryBot.create(:employee) do |e|
    FactoryBot.create(:contract, :works_mondays, :active, employee: e)
  end
end

def employee_shift_now
  FactoryBot.create(:employee) do |e|
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        FactoryBot.create(:shift, schedule: s)
        c.schedule_id = s.id
        c.save
      end
    end
  end
end

def employee_shift_past
  FactoryBot.create(:employee) do |e|
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        FactoryBot.create(:shift, :past, schedule: s)
        c.schedule_id = s.id
        c.save
      end
    end
  end
end
