class Demand < ApplicationRecord
  # todo might need a cleanup...
  before_save :truncate_time, :calculate_year, :calculate_week,

  def truncate_time
    self.start_time = self.start_time.change(:min => 0)
    self.end_time = self.end_time.change(:min => 0)
  end

  def calculate_week
    self.week = self.start_time.to_date.cweek
  end

  def calculate_year
    self.year = self.start_time.year
  end

  scope :in_year, -> (year) { where('year = ?', year) }

  scope :in_week, -> (year, week) { where(year: year, week: week) }
end
