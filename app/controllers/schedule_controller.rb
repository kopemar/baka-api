class ScheduleController < ApplicationController
  # include DeviseTokenAuth::Concerns::SetUserByToken

  # before_action :authenticate_user!
  def get_all
    render json: SchedulingService.new.generate_schedule(2020, 49)
  end
end
