class EmploymentContract < Contract
  validates_presence_of :work_load, :working_days
end
