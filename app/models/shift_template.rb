class ShiftTemplate < ApplicationRecord
  before_validation :count_duration, :add_to_scheduling_unit
  validate :validate_time, :validate_duration

  belongs_to :scheduling_unit

  def count_duration
    logger.debug "count_duration"
    self.duration = ((end_time - start_time - break_minutes.minutes).to_f / 1.hour)
  end

  def validate_duration
    unless self.duration <= 12
      errors.add("Duration is too long")
    end
    unless self.duration > 0
      errors.add("Break longer than shift...")
    end
  end

  def validate_time
    unless self.start_time.before?(self.end_time)
      errors.add("Start time has to be before end time")
    end
  end

  def add_to_scheduling_unit
    logger.debug "add to scheduling unit"
    self.scheduling_unit = SchedulingUnit.where("end_time >= ? AND start_time <= ?", start_time, start_time).first
  end
end
