class SchedulingService < ApplicationService

  def initialize(start_date, end_date, split)
    @start_date = start_date
    @end_date = end_date
    @split = split == 0 ? 3 : split
    @logger = Logger.new(STDOUT)
  end

  def call
    days = (@end_date - @start_date).to_i + 1
    # DemandService.call(date, @days.days.after(date))
    employees = Employee.to_be_planned(@start_date, @end_date)

    @logger.debug "Employees to schedule: #{employees.map(&:username)}"

    partial_schedule = Shift.planned_between(@start_date, @end_date).to_set
    days.times do |d|
      date = d.days.after(@start_date)
      p "========================= scheduling for #{date.wday} #{date} =========================".upcase
      employees.each do |n|
        last = n.get_last_scheduled_shift_before(date)
        if n.can_work_at(date, @start_date, @end_date)
          hour = rand(0..28)
          unless hour > 16
            start = hour.hours.after(date.midnight)
            end_time = STANDARD_DAILY_WORKING_HOURS.hours.after(start)
            schedule = n.get_schedule_for_shift_time(start, end_time)
            partial_schedule.add(n.last)
            @logger.debug "ALL SCHEDULES OF #{n.id} -> "
            @logger.debug "Employee #{n.id} -> schedule #{schedule.id unless schedule.nil?}"
            unless schedule.nil?
              n.last = Shift.create!(start_time: start, end_time: end_time, schedule_id: schedule.id)
              @logger.debug "Created shift #{n.last}"
            end
          end
        end
      end
    end

    schedule = Set.new
    employees.each do |e|
      schedule.add(UserScheduleService.call(e, @start_date, @end_date))
    end
    Shift.planned_between(@start_date, @end_date)
  end


end