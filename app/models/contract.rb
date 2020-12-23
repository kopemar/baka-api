class Contract < ApplicationRecord
  validates :schedule_id, uniqueness: true
  belongs_to :employee, optional: true

  has_one :schedule

  def type_to_id
    if self.type == "EmploymentContract"
      1
    elsif self.type == "AgreementToCompleteAJob"
      2
    elsif self.type == "AgreementToPerformAJob"
      3
    else
      0
    end
  end

  def active
    (end_date.after?(Date.today) && start_date.before?(Date.today)) || end_date == nil
  end

  scope :active_employment_contracts, -> { where(type: "EmploymentContract")
                                               .where("end_date >= ? OR end_date IS NULL", Date::today)
                                               .where("start_date <= ?", Date::today)
  }

  scope :shifts_planned, -> (start_time, end_time) { joins(:schedule).merge(Schedule.planned_between(start_time, end_time)) }

  scope :with_no_shifts_planned_in, -> (start_time, end_time) { Contract.where.not(id: Contract.shifts_planned(start_time, end_time)) }

  def as_json(*args)
    hash = super(*args)
    hash.merge!(active: self.active)
    hash.merge!(type: type_to_id)
    hash.merge!(schedules: self.schedule)
  end
end
