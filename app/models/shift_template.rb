class ShiftTemplate < ApplicationRecord
  before_save :count_duration
  validate :validate_time

  def count_duration
    logger.debug "count_duration"
    self.duration = ((end_time - start_time - break_minutes.minutes).to_f / 1.hour)
  end

  def validate_time
    self.start_time.before?(self.end_time)
  end
end
