class ScheduleController < ApplicationController
  # include DeviseTokenAuth::Concerns::SetUserByToken

  # before_action :authenticate_user!
  def schedule
    render json: SchedulingService.call(params[:year].to_i, params[:week].to_i, params[:days].to_i, params[:split].to_i)
  end
end
