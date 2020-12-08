class SchedulingService < ApplicationService

  def initialize(year, week, days, split)
    @year = year
    @week = week
    @days = days.nil? ? 7 : days
    @split = split.nil? ? 3 : split
  end

  def call
    day = 0
    date = Date.commercial(@year, @week + (day/7).floor, day % 7 + 1)
    DemandService.call(date, @days.days.after(date))
    employees = Employee::with_employment_contract
    @days.times do |day|
      # todo new year!
      date = Date.commercial(@year, @week + (day/7).floor, day % 7 + 1)
      p "========================= scheduling for #{date} =========================".upcase
      employees.each_slice(@split) do |a|
        a.each { |n|
          if n.can_work_at(date, date, @days.days.after(date))
            p "========================= #{n.username} can work at #{date} ========================="
            hour = rand(0..28)
            unless hour > 16
              start = hour.hours.after(date.midnight)
              Shift.create!(start_time: start, end_time: 8.hours.after(start), schedule_id: n.contracts.first.schedule.id)
            end
          end
        }
      end
    end
    Schedule.all
    # nil
  end



end