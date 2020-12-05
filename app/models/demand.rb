class Demand < ApplicationRecord
  before_save :calculate_year, :calculate_week

  def calculate_week
    self.week = self.start_time.to_date.cweek
  end

  def calculate_year
    self.year = self.start_time.year
  end

  scope :in_year, -> (year) { where('year = ?', year) }
end
