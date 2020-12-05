class SchedulingService

  def generate_schedule (year, week, days = 7, split = 3)
    employees = Employee::with_employment_contract
    # todo get working days for period...

    days.times do |day|
      # todo new year!
      date = Date.commercial(year, week + (day/7).floor, day % 7 + 1)
      p "========================= scheduling for #{date} ========================="

      employees.each_slice(split) do |a|
        a.each { |n|
          if n.can_work_at(date, date, days.days.after(date))
            "========================= #{n.username} can work at #{date} ========================="
          end
        }
      end
    end
  end
  nil
end