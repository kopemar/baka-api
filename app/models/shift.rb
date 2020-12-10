class Shift < ApplicationRecord
  validates :start_time, :end_time, :overlap => { :exclude_edges => %w[start_time end_time], :scope => "schedule_id" }
  belongs_to :schedule

  scope :planned_between, -> (start_date, end_date) {
    where("shifts.start_time BETWEEN ? AND ? ", start_date, end_date)
        .or(where("shifts.end_time BETWEEN ? AND ? ", start_date, end_date))
        .or(where("shifts.start_time <= ? AND shifts.end_time >= ?", start_date, end_date))
  }
end
