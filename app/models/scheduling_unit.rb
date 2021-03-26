#days
class SchedulingUnit < ApplicationRecord
  before_validation :add_scheduling_period
  validates :start_time, :end_time, :overlap => {:exclude_edges => %w[start_time end_time], :scope => "scheduling_period_id"}

  belongs_to :scheduling_period
  has_many :shift_templates, foreign_key: :scheduling_unit_id

  # after_save :generate_shift_templates

  def add_scheduling_period
    self.scheduling_period = SchedulingPeriod.where("end_date >= ? AND start_date <= ?", start_time.to_date, start_time.to_date).where(organization_id: self.organization_id).first
  end

  # generates shift templates for employment contract employees
  def create_shift_template(start_time, end_time, break_minutes, is_excluded = false)
    st = start_time.hour.hours.after(start_time.min.minutes.after(self.start_time.to_date))
    en = end_time.hour.hours.after(end_time.min.minutes.after(self.start_time.to_date))
    if start_time.to_time > end_time.to_time
      en = end_time.hour.hours.after(self.start_time.to_date)
    end
    ShiftTemplate.create!(
        start_time: st,
        end_time: en,
        break_minutes: break_minutes,
        organization_id: self.organization_id,
        is_employment_contract: true,
        excluded: is_excluded
    )
  end

  scope :in_scheduling_period, -> (period_id) {
    where(scheduling_period_id: period_id)
  }

  def is_day?
    true
  end

  def as_json(*args)
    hash = super(*args)
    hash.merge({is_day: is_day?})
  end

end