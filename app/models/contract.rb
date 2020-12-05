class Contract < ApplicationRecord
  belongs_to :employee, optional: true

  def active
    (end_date.after?(Date.today) && start_date.before?(Date.today)) || end_date == nil
  end

  scope :active_employment_contracts, -> { where(type: "EmploymentContract")
                                               .where("end_date >= ? OR end_date IS NULL", Date::today)
                                               .where("start_date <= ?", Date::today)
  }

  def as_json(*args)
    hash = super(*args)
    hash.merge!(active: self.active)
  end
end
