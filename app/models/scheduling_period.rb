# weeks
class SchedulingPeriod < ApplicationRecord
  # after_save :generate_scheduling_units
  #
  # validates :start_date, :end_date, :overlap => {
  #     :query_options => {:joins => :organization}
  # }
  belongs_to :organization
  has_many :scheduling_units

  def generate_scheduling_units
    ((self.end_date - self.start_date).to_i + 1).times do |i|
      SchedulingUnit.create!(start_time: i.days.after(self.start_date).to_datetime.midnight, end_time: i.days.after(self.start_date).to_datetime.end_of_day, scheduling_period: self, organization_id: self.organization_id)
    end
  end
end
