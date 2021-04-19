require_relative '../services/scheduling/scheduling'

class SchedulingPeriodController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def index
    unless params[:from].nil?
      return render json: {
          :periods => @collection = SchedulingPeriod.accessible_by(current_ability).where("end_date >= ?", params[:from]).paginate(page: params[:page], per_page: params[:per_page].nil? ? 30 : params[:per_page]),
          :current_page => @collection.current_page,
          :total_pages => @collection.total_pages,
          :has_next => @collection.next_page.present?
      }
    end
    render json: {
        :periods => @collection = SchedulingPeriod.accessible_by(current_ability).paginate(page: params[:page], per_page: params[:per_page].nil? ? 30 : params[:per_page]),
        :current_page => @collection.current_page,
        :total_pages => @collection.total_pages,
        :has_next => @collection.next_page.present?
    }
  end

  def update
    @scheduling_period = SchedulingPeriod.accessible_by(current_ability, :update).find(params[:id])

    @scheduling_period.update! permitted_params

    if params[:submitted]
      employees = period.assigned_employees
      NotificationHelpers.send_notification(
          employees,
          {
              priority: "high",
              notification: {
                  body: "New schedule submitted!",
                  title: "Schedule for #{period.start_date} - #{period.end_date} was submitted"
              }
          }
      )
    end

    render :status => :ok, :json => { data: @scheduling_period }
  end

  def calculate_shift_times
    params.require([:shift_hours, :break_minutes, :per_day])
    params.permit(:shift_hours, :break_minutes, :per_day, :night_shift, :is_24_hours, :shift_start, :start_time, :end_time)

    if params[:is_24_hours] == true.to_s
      params.require(:shift_start)
    else
      params.require([:start_time, :end_time])
    end

    render :json => {:times => ShiftTimesCalcService.call(params)}
  rescue ShiftTimesCalcService::ShiftServiceError => e
    Rails.logger.debug "Reason: #{e}"
    render :status => :bad_request, :json => {:errors => [e.message]}
  end

  def generate_shift_templates
    params.require([:start_time, :end_time, :shift_hours, :break_minutes, :per_day])
    params.permit(:night_shift)
    render :status => :created, :json => { :data => ShiftTemplateGenerator.call(params) }
  end

  def get_unit_dates_for_period
    period = SchedulingPeriod.where(id: params[:id]).first
    if period.nil?
      render :status => :bad_request, :json => {:errors => ["Schedule period ID is invalid."]}
    end
    days = []
    days_count = (period.end_date - period.start_date).to_i + 1

    days_count.times do |n|
      days.push({:date => n.days.after(period.start_date).to_date, :id => n + 1})
    end
    render :json => {:days => days}
  end

  def generate_schedule
    unless current_user.manager?
      return render :status => :forbidden, :json => {:errors => ["Only managers can call this"]}
    end
    permitted = params.permit(:id, priorities: [:no_empty_shifts, :demand_fulfill])
    result = Scheduling::Scheduling.new(permitted).call
    render :json => { :success => true, :violations => result }
  end

  def show
    period = SchedulingPeriod.accessible_by(current_ability).find(params[:id])

    render :json => period
  end

  private

  def permitted_params
    params.permit(:submitted)
  end

end
