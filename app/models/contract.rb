class Contract < ApplicationRecord
  belongs_to :employee, optional: true

  def active?
    (self.end_date.after?(Date.today) && self.start_date.before?(Date.today)) || self.end_date == nil
  end

  scope :active_employment_contracts, -> { where(type: "EmploymentContract").select(&:active?) }
end
