# weeks
class SchedulingPeriod < ApplicationRecord
  belongs_to :organization
  has_many :scheduling_units

  def generate_scheduling_units
    ((self.end_date - self.start_date).to_i + 1).times do |i|
      SchedulingUnit.create(start_time: i.days.after(self.start_date).to_datetime.midnight, end_time: i.days.after(self.start_date).to_datetime.end_of_day, scheduling_period: self, organization_id: self.organization_id)
    end
  end

  def generate_scheduling_units_in(days)
    ((self.end_date - self.start_date).to_i + 1).times do |i|
      logger.debug "index: #{i}, include: #{days.include?(i + 1)}, days: #{days}"
      if days.include?(i + 1) && scheduling_units.where(start_time: i.days.after(self.start_date).to_datetime.midnight).empty?
        SchedulingUnit.create!(start_time: i.days.after(self.start_date).to_datetime.midnight, end_time: i.days.after(self.start_date).to_datetime.end_of_day, scheduling_period: self, organization_id: self.organization_id)
      end
    end
    self.scheduling_units
  end

  def is_week?
    true
  end
end
