class SchedulingPeriodController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!
  def all
    unless params[:from].nil?
      return render json: {
          :periods => @collection = SchedulingPeriod.where(organization_id: current_user.organization_id).where("end_date >= ?", params[:from]).paginate(page: params[:page], per_page: params[:per_page].nil? ? 30 : params[:per_page]),
          :current_page => @collection.current_page,
          :total_pages => @collection.total_pages,
          :has_next => @collection.next_page.present?
      }
    end
    render json: {
        :periods => @collection = SchedulingPeriod.where(organization_id: current_user.organization_id).paginate(page: params[:page], per_page: params[:per_page].nil? ? 30 : params[:per_page]),
        :current_page => @collection.current_page,
        :total_pages => @collection.total_pages,
        :has_next => @collection.next_page.present?
    }
  end

  def calculate_shift_times
    render :json => {:times => ShiftTimesCalcService.call(params)}
  rescue ShiftTimesCalcService::ShiftServiceError => e
    render :status => :bad_request, :json => {:errors => [e.message]}
  end
end
