class SchedulingService
  def generate_schedule (days = 7, split = 3)
    employees = Employee::with_employment_contract
    days.times do
      employees.each_slice(split) do |a|

      end
    end
  end
  nil
end