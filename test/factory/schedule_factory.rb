FactoryBot.define do
  factory :schedule do
    contract
  end
end

def schedule_shift_now
  tmpl = get_shift_now
  FactoryBot.create(:employee, organization_id: tmpl.organization_id) do |e|
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save

        shift = Shift.from_template(tmpl)
        shift.schedule_id = s.id
        shift.save!
        return c
      end
    end
  end
end

def schedule_shift_past
  tmpl = get_shift_2019
  FactoryBot.create(:employee, organization_id: tmpl.organization_id) do |e|
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        c.schedule_id = s.id
        c.save!

        shift = Shift.from_template(tmpl)
        shift.schedule_id = s.id
        shift.save
        p c
        return c
      end
    end
  end
end