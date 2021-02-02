#days
class SchedulingUnit < ApplicationRecord
  before_validation :add_scheduling_period

  belongs_to :scheduling_period

  # after_save :generate_shift_templates

  def add_scheduling_period
    self.scheduling_period = SchedulingPeriod.where("end_date >= ? AND start_date <= ?", start_time.to_date, start_time.to_date).where(organization_id: self.organization_id).first
  end

  # generates shift templates for employment contract employees
  # def generate_shift_templates
  #   3.times do |n|
  #     start = (n*8).hours.after(start_time.midnight)
  #     break_min = 30
  #     ShiftTemplate.create!(
  #         start_time: start,
  #         break_minutes: break_min,
  #         end_time: STANDARD_DAILY_WORKING_HOURS.hours.after(break_min.minutes.after(start)),
  #         priority: 0,
  #         scheduling_unit_id: self.id,
  #         organization_id: self.organization_id,
  #         is_employment_contract: true
  #     )
  #   end
  # end

  def is_day?
    true
  end

  def as_json(*args)
    hash = super(*args)
    hash.merge({is_day: is_day?})
  end

end