class Shift < ApplicationRecord
  validates :start_time, :end_time,
            :overlap => {:exclude_edges => %w[start_time end_time],
                         :scope => "schedule_id IS NOT NULL"}

  belongs_to :schedule, optional: true
  before_save :count_duration

  def count_duration
    self.duration = ((end_time - start_time).to_i / 1.hour)
  end

  scope :unassigned, -> {
    where(schedule_id: nil)
  }

  scope :planned_between, -> (start_date, end_date) {
    where("shifts.start_time BETWEEN ? AND ? ", start_date, end_date)
        .or(where("shifts.end_time BETWEEN ? AND ? ", start_date, end_date))
        .or(where("shifts.start_time <= ? AND shifts.end_time >= ?", start_date, end_date))
  }

  scope :planned_before, -> (end_time) {
    where("shifts.end_time <= ? ", end_time)
  }

  scope :planned_after, -> (start_time) {
    where("shifts.start_time >= ? ", start_time)
  }
end
