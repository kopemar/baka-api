class ScheduleController < ApplicationController
  def get_all
    render json: SchedulingService.new.generate_schedule
  end
end
