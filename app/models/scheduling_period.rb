class SchedulingPeriod < ApplicationRecord
  validates :start_date, :end_date, :overlap
  has_many :scheduling_units
end
