require_relative '../services/scheduling/scheduling'

class SchedulingPeriodController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def index
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

  def update
    @scheduling_period = SchedulingPeriod::filter_by_organization(current_user.organization_id).find(params[:id])

    @scheduling_period.update! permitted_params

    render :status => :ok, :json => { data: @scheduling_period }
  end

  def calculate_shift_times
    params.require([:start_time, :end_time, :shift_hours, :break_minutes, :per_day])
    params.permit(:night_shift)

    render :json => {:times => ShiftTimesCalcService.call(params)}
  rescue ShiftTimesCalcService::ShiftServiceError => e
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
    unless current_user.is_manager?
      return render :status => :forbidden, :json => {:errors => ["Only managers can call this"]}
    end
    permitted = params.permit(:id, priorities: [:no_empty_shifts, :demand_fulfill])
    result = Scheduling::Scheduling.new(permitted).call
    render :json => {:errors => ["No errors, just test message"], :success => true, :violations => result}
  end

  def show
    period = SchedulingPeriod.find(params[:id])
    if period.organization_id != current_user.organization_id
      return render :status => :forbidden, :json => {:errors => ["This period is not within your organization."]}
    end
    unless current_user.is_manager?
      return render :status => :forbidden, :json => {:errors => ["Only managers and higher can access this resource."]}
    end
    render :json => period
  end

  def submit
    unless current_user.is_manager?
      return render :status => :forbidden, :json => {:errors => ["Only managers can call this"]}
    end
    period = SchedulingPeriod.where(id: params[:id]).first
    if period.nil?
      return render :status => :not_found, :json => {:errors => ["Schedule period does not exist."]}
    end

    employees = period.assigned_employees

    period.submitted = true
    # todo already submitted?
    period.save!

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

    render :status => :ok, :json => {:success => true, :data => period}
  end

  private

  def permitted_params
    params.permit(:submitted)
  end

end
