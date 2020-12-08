class UserScheduleService < ApplicationService

  def initialize(current_user)
    @user = current_user
  end

  def call
    set = Set.new
    @user.contracts.each do |contract|
      set.merge(contract.schedule.shifts)
    end
    set.sort_by { |d| d.start_time}
  end

end
