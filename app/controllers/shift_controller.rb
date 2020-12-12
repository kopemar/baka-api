class ShiftController < ApplicationController
  before_action :authenticate_user!
  def get_user_schedule
    return render json: { :shifts => UserScheduleService.call(current_user, params[:start_date].to_date, params[:end_date].to_date)} unless params[:start_date].nil? || params[:end_date].nil?
    render json: { :shifts => UserScheduleService.call(current_user) }
  end
end
