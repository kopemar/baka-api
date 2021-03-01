class EmploymentContract < Contract
  validates_presence_of :work_load, :working_days
  validates :start_date, :end_date, :overlap => {:exclude_edges => %w[start_time end_time], :scope => "employee_id"}
end
