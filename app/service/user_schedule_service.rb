class UserScheduleService < ApplicationService

  def initialize(current_user, start_date = nil, end_date = nil)
    @user = current_user
    @start_date = start_date
    @end_date = end_date
  end

  def call
    set = Set.new
    @user.contracts.each do |contract|
      if @start_date.nil? || @end_date.nil?
        set.merge(contract.schedule.shifts)
      else
        set.merge(contract.schedule.shifts.planned_between(@start_date, @end_date))
      end
    end
    set.sort_by { |d| d.start_time}
  end

end
