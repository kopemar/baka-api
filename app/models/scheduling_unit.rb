#days
class SchedulingUnit < ApplicationRecord
  before_save :add_scheduling_period

  belongs_to :scheduling_period

  def add_scheduling_period
    self.scheduling_period = SchedulingPeriod.where("end_date >= ? AND start_date <= ?", start_time.to_date, start_time.to_date).first
  end

  def is_day?
    true
  end

  def as_json(*args)
    hash = super(*args)
    hash.merge({is_day: is_day?})
  end
end