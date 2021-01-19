class Shift < ApplicationRecord
  validates :start_time, :end_time,
            :overlap => {:exclude_edges => %w[start_time end_time],
                         :scope => "schedule_id"}

  validates_presence_of :schedule_id

  belongs_to :schedule, optional: true
  belongs_to :shift_template

  before_save :count_duration

  def count_duration
    self.duration = ((end_time - start_time).to_i / 1.hour)
  end

  def self.from_template(template)
    Shift.new(
        start_time: template.start_time,
        end_time: template.end_time,
        shift_template_id: template.id,
        duration: template.duration,
        break_minutes: template.break_minutes
    )
  end

  scope :planned_between, -> (start_date, end_date) {
    where("shifts.end_time >= ? AND shifts.start_time <= ?", start_date, end_date)
  }

  scope :planned_before, -> (end_time) {
    where("shifts.end_time <= ? ", end_time)
  }

  scope :planned_after, -> (start_time) {
    where("shifts.start_time >= ? ", start_time)
  }

  scope :for_user, -> (user) {
    Shift.where(schedule: Schedule.where(contract: Contract.where(employee_id: user.id)))
  }
end
