FactoryBot.define do
  factory :shift_template do
    sequence(:start_time, 1) { |n| (12 * n).hours.from_now }
    end_time { 8.hours.after(start_time) }

    trait :sequence_24_h do
      sequence(:start_time, 1) { |n| (24 * n).hours.from_now }
      end_time { 8.hours.after(start_time) }
    end

    trait :past_2019 do
      start_time { "2019-12-30".to_datetime }
      end_time { 8.hours.after(start_time) }
    end

    trait :past do
      start_time { 3.days.ago }
      end_time { 8.hours.after(start_time) }
    end

    trait :now do
      start_time { 0.hours.from_now }
      end_time { 8.hours.from_now }
    end

    trait :future do
      start_time { 1.month.from_now }
      end_time { 8.hours.after(start_time) }
    end
  end
end

def create_shifts_happening_now
  tmpl = get_shift_now
  FactoryBot.build_list(:employee, 5) do |e|
    e.organization_id = tmpl.organization_id
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save!

        s1 = Shift.from_template(tmpl)
        s1.schedule_id = s.id
        s1.save
      end
    end
    e.save!
  end

  # FactoryBot.create_list(:employee, 2) do |e|
  #   FactoryBot.create(:contract, :active, employee: e) do |c|
  #     FactoryBot.create(:schedule, contract: c) do |s|
  #       c.schedule_id = s.id
  #       c.save!
  #     end
  #   end
  # end
end

def create_shifts_past_future
  tmpl_past = get_shift_2019
  FactoryBot.build_list(:employee, 5) do |e|
    e.organization_id = tmpl_past.id
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        s1 = Shift.from_template(tmpl_past)
        s1.schedule_id = s.id
        s1.save

        s2 = Shift.from_template(FactoryBot.create(:shift_template, :future))
        s2.schedule_id =  s.id
        s2.save

        c.schedule_id = s.id
        c.save!
      end
    end
    e.save
  end

  FactoryBot.build_list(:employee, 2) do |e|
    e.organization_id = o.id
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        s1 = Shift.from_template(FactoryBot.create(:shift_template, :past))
        s1.schedule_id = s.id
        s1.save
        c.schedule_id = s.id
        c.save!
      end
    end
    e.save
  end
end

def create_employee_shifts_past
  tmp = get_shift_2019
  FactoryBot.create(:employee, organization_id: tmp.organization_id) do |e|
    FactoryBot.create_list(:contract, 2, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save!
        s1 = Shift.from_template(tmp)
        s1.schedule_id = s.id
        s1.save
      end
    end
  end
end