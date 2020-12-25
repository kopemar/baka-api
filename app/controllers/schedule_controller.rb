class ScheduleController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken

  def schedule
    SchedulingService.call(params[:start_date].to_date, params[:end_date].to_date, params[:split].to_i)
    render json: Shift.planned_between(params[:start_date].to_date, params[:end_date].to_date).where.not(schedule_id: nil).paginate(page: params[:page], per_page: 30)
  end

  before_action :authenticate_user!

  def assign_shift
    contract = Contract::active_agreements.where(employee_id: current_user.id).where(schedule_id: params[:id]).first
    unless contract.nil?
      shift = Shift.where(id: params[:shift_id]).first
      if shift.schedule_id.nil?
        shift.schedule_id = contract.schedule_id
        shift.save!
        return render json: shift
      end
    end
    render :status => :bad_request
  end
end
