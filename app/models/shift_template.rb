class ShiftTemplate < ApplicationRecord
  include Filterable

  before_validation :count_duration, :add_to_scheduling_unit
  validate :validate_time, :validate_duration, :validate_priority

  belongs_to :scheduling_unit
  belongs_to :specialization, required: false

  has_many :shifts

  has_many :sub_templates, class_name: 'ShiftTemplate', foreign_key: :parent_template_id

  belongs_to :parent_template, class_name: 'ShiftTemplate', optional: true

  def count_duration
    self.duration = ((end_time - start_time - break_minutes.minutes).to_f / 1.hour)
  end

  def validate_priority
    if self.priority > 5 || self.priority < 0
      errors.add("Priority is too big")
    end
  end

  def validate_duration
    unless self.duration <= MAX_SHIFT_DURATION_HOURS
      errors.add("Duration is too long")
    end
    unless self.duration > 0
      errors.add("Break longer than shift...")
    end
  end

  def validate_time
    unless self.start_time.to_datetime.before?(self.end_time.to_datetime)
      errors.add("Start time has to be before end time #{self.start_time} #{self.end_time}")
    end
  end

  def can_be_user_assigned?
    !is_employment_contract
  end

  scope :planned_between, -> (start_date, end_date) {
    where("end_time >= ? AND start_time <= ?", start_date, end_date)
  }

  scope :planned_before, -> (end_time) {
    where("end_time <= ? ", end_time)
  }

  scope :planned_after, -> (start_time) {
    where("start_time >= ? ", start_time)
  }

  scope :can_be_user_scheduled, -> { where(is_employment_contract: false).or(joins(:scheduling_unit).where(scheduling_units: {scheduling_period: SchedulingPeriod.where(submitted: true) })) }

  scope :to_be_auto_scheduled, -> { where(is_employment_contract: true) }

  scope :in_scheduling_period, -> (period_id) {
    where(scheduling_unit_id: SchedulingPeriod.where(id: period_id).first.scheduling_units.map(&:id))
  }

  scope :filter_by_organization, -> (org_id) {
    joins(:scheduling_unit).where(scheduling_units: {
        scheduling_period: SchedulingPeriod.where(organization_id: org_id)
    })
  }

  scope :filter_by_unassigned, -> (value) {

  }

  scope :filter_by_unit, -> (unit_id) {
    where(scheduling_unit_id: unit_id)
  }

  def add_to_scheduling_unit
    logger.debug "add to scheduling unit"
    self.scheduling_unit = SchedulingUnit.where("end_time >= ? AND start_time <= ?", start_time, start_time).where(organization_id: self.organization_id).first
  end

  def as_json(*args)
    s = nil
    s = specialization.name unless specialization.nil?
    super(*args).merge({shifts_count: Shift.where(shift_template_id: self.id).count, specialization: s})
  end
end
