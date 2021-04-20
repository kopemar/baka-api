# weeks
class SchedulingPeriod < ApplicationRecord
  include Filterable

  belongs_to :organization
  has_many :scheduling_units

  def assigned_employees
    Employee.joins(:contracts).where(contracts: {
        schedule_id: Shift.select(:schedule_id).joins(:shift_template).where(
            shift_templates: {
                scheduling_unit: self.scheduling_units
            }).map(&:schedule_id)}).to_a
  end

  def generate_scheduling_units
    ((self.end_date - self.start_date).to_i + 1).times do |i|
      SchedulingUnit.create(start_time: i.days.after(self.start_date).to_datetime.midnight, end_time: i.days.after(self.start_date).to_datetime.end_of_day, scheduling_period_id: self.id, organization_id: self.organization_id)
    end
  end

  def generate_scheduling_units_in(days)
    ((self.end_date - self.start_date).to_i + 1).times do |i|
      logger.debug "index: #{i}, include: #{days.include?(i + 1)}, days: #{days}"
      if days.include?(i + 1) && scheduling_units.where(start_time: i.days.after(self.start_date).to_datetime.midnight).empty?
        SchedulingUnit.find_or_create_by!(start_time: i.days.after(self.start_date).to_datetime.midnight, end_time: i.days.after(self.start_date).to_datetime.end_of_day, scheduling_period_id: self.id, organization_id: self.organization_id)
      end
    end
    self.scheduling_units
  end

  def is_week?
    true
  end

  scope :filter_by_from, -> (start_date) {
    where("end_date >= ?", start_date.to_date)
  }

  scope :filter_by_organization, -> (organization_id) {
    where(organization_id: organization_id)
  }
end
