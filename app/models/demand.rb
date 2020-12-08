class Demand < ApplicationRecord
  before_save :truncate_time

  validates :start_time, :end_time, :overlap => {:exclude_edges => %w[start_time end_time]}
  validate :validate_date

  def duration
    (self.end_time - self. start_time).to_i
  end

  DEMAND = {
      none: 0,
      lower: 1,
      low: 2,
      medium: 3,
      high: 4,
      highest: 5
  }

  scope :for_date, -> (date) { where(:start_date => date) }

  scope :between, -> (start_date, end_date) { where("demands.start_date BETWEEN ? AND ?", start_date, end_date) }

  private def truncate_time
    self.start_date = self.start_time.change(:hour => 0)
    self.end_date = self.end_time.change(:hour => 0)
    self.start_time = self.start_time.change(:min => 0)
    self.end_time = self.end_time.change(:min => 0)
  end

  private def validate_date
    if self.start_time > self.end_time
      self.errors[:base] << "Start time has to be before end time!"
    end
    if ((self.end_time - self.start_time) / 1.hour) >= 24
      self.errors[:base] << "Demand can only be defined for 24 hours!"
    end
    if ((end_time - start_time.end_of_day) / 1.hour) > STANDARD_DAILY_WORKING_HOURS
      self.errors[:base] << "Demand can only end #{STANDARD_DAILY_WORKING_HOURS} hours after end of start_day"
    end
  end
end
