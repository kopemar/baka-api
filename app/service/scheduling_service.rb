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
    # DemandService.call(date, @days.days.after(date))
    employees = Employee.to_be_planned(date, @days.days.after(date))
    employees
    # partial_schedule = Set.new
    # @days.times do |d|
    #   # todo new year!
    #   date = Date.commercial(@year, @week + (d/7).floor, d % 7 + 1)
    #   p "========================= scheduling for #{date} =========================".upcase
    #   employees.each_slice(@split) do |a|
    #     a.each { |n|
    #       last = n.get_last_scheduled_day_before(date)
    #       if !last.nil?
    #         p "=============== LAST #{n.username}: #{last.start_time}================="
    #       else
    #         p "=============== LAST #{n.username}: nil ================="
    #       end
    #       if n.can_work_at(date, date, @days.days.after(date))
    #         p "========================= #{n.username} can work at #{date} ========================="
    #         hour = rand(0..28)
    #         p "========================= #{n.username} works at #{date} : #{!(hour > 16)} ========================="
    #         unless hour > 16
    #           start = hour.hours.after(date.midnight)
    #           p Shift.where(schedule_id: n.contracts.first.schedule.id).where('shifts.start_time <= ? AND shifts.end_time >= ?', start, start)
    #           p "xxxxxxxxxxxxxxxxxxxxxxxx #{n.id} : #{start} xxxxxxxxxxxxxxxxxxxxxxxx"
    #           # n.last = Shift.create!(start_time: start, end_time: STANDARD_DAILY_WORKING_HOURS.hours.after(start), schedule_id: n.contracts.first.schedule.id)
    #           # partial_schedule.add(n.last)
    #         end
    #       end
    #     }
    #   end
    # end
    # partial_schedule
    # nil
  end



end