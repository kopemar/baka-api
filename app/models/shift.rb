class Shift < ApplicationRecord
  validates :start_time, :end_time, :overlap => { :exclude_edges => %w[start_time end_time], :scope => "schedule_id" }
end
