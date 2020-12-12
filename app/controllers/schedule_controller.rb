class ScheduleController < ApplicationController
  # include DeviseTokenAuth::Concerns::SetUserByToken
  def schedule
    render json: SchedulingService.call(params[:start_date].to_date, params[:end_date].to_date, params[:split].to_i)
  end
end
