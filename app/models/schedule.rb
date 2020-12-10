class Schedule < ApplicationRecord
  belongs_to :contract

  has_many :shifts

  scope :planned_between, -> (start_date, end_date) { joins(:shifts).merge!(Shift.planned_between(start_date, end_date)) }

  scope :not_planned_between, -> (start_date, end_date) { joins(:shifts).where.not(id: Shift.planned_between(start_date, end_date)) }

  def as_json(*args)
    hash = super(*args)
    hash.merge!(shifts: self.shifts)
  end
end
