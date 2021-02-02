FactoryBot.define do
  factory :scheduling_period do
    start_date { DateTime::now.monday }
    end_date { DateTime::now.sunday }

    trait :past_2019 do
      start_date { "2019-12-30".to_datetime.monday }
      end_date { "2019-12-30".to_datetime.sunday }
    end

    trait :future do
      start_date { 1.month.from_now.monday }
      end_date { 1.month.from_now.sunday }
    end
  end

  factory :employee do
    type { "Employee" }
    first_name { "Alice" }
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
  o = generate_organization
  FactoryBot.build(:employee) do |e|
    e.organization_id = o.id
    FactoryBot.create(:contract, :inactive, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save
      end
      e.save
    end
    FactoryBot.build(:contract, :active, employee: e) do |c|
      e.organization_id = o.id
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save
      end
    end
  end
end

def employee_two_active_contracts
  o = generate_organization
  FactoryBot.build(:employee) do |e|
    e.organization_id = o.id
    FactoryBot.create_list(:contract, 2, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save
      end
    end
    e.save
  end
end

def employee_inactive_contracts
  FactoryBot.build(:employee) do |e|
    FactoryBot.create_list(:contract, 2, :inactive, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save
      end
    end
  end
end

def employee_with_no_contract
  o = generate_organization
  FactoryBot.build(:employee) do |e|
    e.organization_id = o.id
    e.save
  end
end

def employee_monday
  o = generate_organization
  FactoryBot.build(:employee) do |e|
    e.organization_id = o.id
    FactoryBot.create(:contract, :works_mondays, :active, employee: e)
    e.save
  end
end

def employee_shift_now
  tmp = get_shift_now
  FactoryBot.build(:employee, organization_id: tmp.organization_id) do |e|
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save

        shift = Shift.from_template(tmp)
        shift.schedule = s
        shift.save!
      end
    end
    e.save
  end
end

def employee_shift_past
  o = generate_organization
  FactoryBot.build(:employee) do |e|
    e.organization_id = o.id
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        FactoryBot.create(:shift_template, :past, schedule: s)
        c.schedule_id = s.id
        c.save
      end
    end
    e.save
  end
end

def get_shift_now
  o = generate_organization
  p = FactoryBot.create(:scheduling_period, organization_id: o.id)
  p.generate_scheduling_units

  FactoryBot.create(:shift_template, organization_id: o.id)
end

def get_shift_2019
  o = generate_organization
  p = FactoryBot.create(:scheduling_period, :past_2019, organization_id: o.id)
  p.generate_scheduling_units

  FactoryBot.create(:shift_template, :past_2019, organization_id: o.id)
end

def get_shift_future
  o = generate_organization
  p = FactoryBot.create(:scheduling_period, :future, organization_id: o.id)
  p.generate_scheduling_units

  FactoryBot.create(:shift_template, :future, organization_id: o.id)
end
