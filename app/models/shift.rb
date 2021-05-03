class Shift < ApplicationRecord
  include Filterable

  validates :start_time, :end_time,
            :overlap => {:exclude_edges => %w[start_time end_time],
                         :scope => "schedule_id"}
  validate :validate_specialization, :validate_priority

  # validates_presence_of :schedule_id

  belongs_to :schedule, optional: true
  belongs_to :shift_template

  before_save :count_duration

  def count_duration
    self.duration = ((end_time - start_time).to_i / 1.hour)
  end

  def validate_specialization
    template_specialization = self.shift_template.specialization
    unless template_specialization.nil?
      errors.add("Could not save shift #{shift_template_id} with this specialization #{template_specialization.id}, must be: #{self.schedule.contract.specializations.map(&:id)}") unless self.schedule.contract.specializations.map(&:id).include? template_specialization.id
    end
  end

  def validate_priority
    template_prio = self.shift_template.priority
    unless template_prio > 0
      errors.add("Could not save shift #{shift_template_id} with this priority #{template_prio}")
    end
  end

  def self.from_template(template, start_time = template.start_time, end_time = template.end_time)
    Shift.new(
        start_time: start_time,
        end_time: end_time,
        shift_template_id: template.id,
        break_minutes: template.break_minutes
    )
  end

  scope :in_scheduling_period, -> (period_id) {
    where(shift_template_id: ShiftTemplate::in_scheduling_period(period_id).map(&:id))
  }

  scope :planned_between, -> (start_date, end_date) {
    where("shifts.end_time >= ? AND shifts.start_time <= ?", start_date, end_date)
  }

  scope :planned_before, -> (end_time) {
    where("shifts.end_time <= ? ", end_time)
  }

  scope :planned_after, -> (start_time) {
    where("shifts.start_time >= ? ", start_time)
  }

  scope :submitted, -> (is_submitted = true) {
    joins(:shift_template).where(shift_templates: {scheduling_unit: SchedulingUnit.joins(:scheduling_period).where(scheduling_periods: { submitted: is_submitted })})
  }

  scope :filter_by_upcoming, -> (add) {
    if add
      return where("shifts.start_time >= ? ", DateTime.now)
    end
    where.not("shifts.start_time >= ? ", DateTime.now)
  }

  scope :for_user, -> (user) {
    Shift.where(schedule: Schedule.where(contract: Contract.where(employee_id: user.id)))
  }

  def as_json(*args)
    hash = super.as_json(*args)
    specialization = self.shift_template.specialization
    hash = hash.merge({ specialization: specialization.name }) unless specialization.nil?
    hash
  end
end
