class ScheduleController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken

  def schedule
    SchedulingService.call(params[:start_date].to_date, params[:end_date].to_date, params[:split].to_i)
    render json: Shift.planned_between(params[:start_date].to_date, params[:end_date].to_date).where.not(schedule_id: nil).paginate(page: params[:page], per_page: 30)
  end

  before_action :authenticate_user!

end
