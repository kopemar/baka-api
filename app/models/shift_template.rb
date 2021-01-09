class ShiftTemplate < ApplicationRecord
  before_save :count_duration, :add_to_scheduling_unit
  validate :validate_time

  belongs_to :scheduling_unit

  def count_duration
    logger.debug "count_duration"
    self.duration = ((end_time - start_time - break_minutes.minutes).to_f / 1.hour)
  end

  def validate_time
    self.start_time.before?(self.end_time)
  end

  def add_to_scheduling_unit
    self.scheduling_unit = SchedulingUnit.where("end_time > ? AND start_time < ?", start_time.to_date, start_time.to_date).first
  end
end
