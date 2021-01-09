# weeks
class SchedulingPeriod < ApplicationRecord
  after_save :generate_scheduling_units
  validates :start_date, :end_date, :overlap => true
  has_many :scheduling_units

  def generate_scheduling_units
    ((self.end_date - self.start_date).to_i + 1).times do |i|
      SchedulingUnit.create!(start_time: i.days.after(self.start_date).to_datetime.midnight, end_time: i.days.after(self.start_date).to_datetime.end_of_day, scheduling_period: self)
    end
  end
end
