class SchedulingService < ApplicationService

  def initialize(start_date, end_date, split)
    @start_date = start_date
    @end_date = end_date
    @split = split == 0 ? 3 : split
    @logger = Logger.new(STDOUT)

    @demand = DemandService.call(start_date, end_date)
  end

  def call
    ActiveRecord::Base.transaction do
      days = (@end_date - @start_date).to_i + 1
    end
    # ActiveRecord::Base.transaction do
    #   days = (@end_date - @start_date).to_i + 1
    #   # DemandService.call(date, @days.days.after(date))
    #   employees = Employee.to_be_planned(@start_date, @end_date)
    #
    #   @logger.debug "Employees to schedule: #{employees.map(&:username)}"
    #
    #   partial_schedule = Shift.planned_between(@start_date, @end_date).to_set
    #   days.times do |d|
    #     date = d.days.after(@start_date)
    #     p "========================= scheduling for #{date.wday} #{date} =========================".upcase
    #     employees.each do |employee|
    #       last = employee.get_last_scheduled_shift_before(date)
    #
    #       if employee.can_work_at?(date)
    #         hours_since_last = employee.last.nil? ? MINIMUM_BREAK_HOURS : ((date.midnight - employee.last.end_time)) / 1.hours
    #         # random starting hours
    #         hours = get_random_working_hours(date, employee)
    #         if hours[:hour] <= 24
    #           start = hours[:hour].hours.after(date.midnight)
    #           end_time = hours[:duration].hours.after(start)
    #           schedule = employee.get_schedule_for_shift_time(start, end_time)
    #           if schedule.nil?
    #             @logger.debug "Cannot plan shift for #{start}, #{end_time} as schedule is nil"
    #           else
    #             @logger.debug "Planning shift for #{start}, #{end_time} as schedule is not nil"
    #             employee.last = Shift.create!(start_time: start, end_time: end_time, schedule_id: schedule.id)
    #             partial_schedule.add(employee.last)
    #           end
    #         end
    #       end
    #     end
    #   end
    #
    #   schedule = Set.new
    #   employees.each do |e|
    #     schedule.add(UserScheduleService.call(e, @start_date, @end_date))
    #   end
    # end
  end



end