FactoryBot.define do
  factory :schedule do
    contract
  end
end
def schedule_shift_now
  FactoryBot.create(:employee) do |e|
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        FactoryBot.create(:shift, schedule: s)
        c.schedule_id = s.id
        c.save
        p c
        return c
      end
    end
  end
end

def schedule_shift_past
  FactoryBot.create(:employee) do |e|
    FactoryBot.create(:contract, :active, employee: e) do |c|
      FactoryBot.create(:schedule, contract: c) do |s|
        FactoryBot.create(:shift, :past, schedule: s)
        c.schedule_id = s.id
        p c
        c.save
        return c
      end
    end
  end
end