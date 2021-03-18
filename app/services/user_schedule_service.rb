class UserScheduleService < ApplicationService

  def initialize(current_user, start_date = nil, end_date = nil)
    @user = current_user
    @start_date = start_date
    @end_date = end_date
  end

  def call
    set = Set.new

    @user.contracts.each do |contract|
        set.add(contract.schedule.id)
    end

    shifts = Shift.where(schedule_id: set)
    if !@start_date.nil? && !@end_date.nil?
      shifts = shifts.planned_between(@start_date, @end_date)
    elsif @start_date.nil? && !@end_date.nil?
      shifts = shifts.planned_before(@end_date)
    elsif @end_date.nil? && !@start_date.nil?
      shifts = shifts.planned_after(@start_date)
    end

    shifts.joins(:shift_template).where(shift_templates: { scheduling_unit: SchedulingUnit.joins(:scheduling_period).where(scheduling_periods: { organization: @user.organization, submitted: true } ) })
  end

end
