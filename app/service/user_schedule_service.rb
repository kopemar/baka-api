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

    if !@start_date.nil? && !@end_date.nil?
      Shift.where(schedule_id: set).planned_between(@start_date, @end_date)
    elsif @start_date.nil?
      Shift.where(schedule_id: set).planned_before(@end_date)
    elsif @end_date.nil?
      Shift.where(schedule_id: set).planned_after(@start_date)
    end

  end

end
