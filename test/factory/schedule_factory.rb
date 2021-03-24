FactoryBot.define do
  factory :schedule do
    contract
  end
end

def schedule_shift_now
  tmpl = get_shift_now
  e = FactoryBot.create(:employee, organization_id: tmpl.organization_id)
  contract = FactoryBot.create(:contract, :active, employee: e)
  shift = Shift.from_template(tmpl)
  shift.schedule_id = contract.schedule_id
  shift.save!
  contract
end

def schedule_shift_past
  tmpl = get_shift_2019
  e = FactoryBot.create(:employee, organization_id: tmpl.organization_id)
  contract = FactoryBot.create(:contract, :active, employee: e)
  shift = Shift.from_template(tmpl)
  shift.schedule_id = contract.schedule_id
  shift.save!
  contract
end