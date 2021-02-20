class ShiftController < ApplicationController
  before_action :authenticate_user!

  def get_shifts
    schedule = if params[:unassigned] == true.to_s
                 get_unassigned_shifts
               elsif params[:start_date].nil? && params[:end_date].nil?
                 UserScheduleService.call(current_user).order(:start_time)
               elsif params[:start_date].nil?
                 UserScheduleService.call(current_user, nil, params[:end_date].to_date).order('shifts.start_time DESC')
               elsif params[:end_date].nil?
                 UserScheduleService.call(current_user, params[:start_date].to_date, nil).order('start_time')
               else
                 UserScheduleService.call(current_user, params[:start_date].to_date, params[:end_date].to_date).order(:start_time)
               end

    render json: {
        :shifts => @collection = schedule.paginate(page: params[:page], per_page: params[:per_page].nil? ? 30 : params[:per_page]),
        :current_page => @collection.current_page,
        :total_pages => @collection.total_pages,
        :has_next => @collection.next_page.present?
    }
  end

  def assign_shift
    if params[:schedule_id].nil? || params[:template_id].nil?
      render :status => :bad_request, :json => {:errors => ["schedule_id not defined"]}
    elsif ShiftTemplate.where(id: params[:template_id]).first.nil?
      render :status => :not_found, :json => {:errors => ["Template not found"]}
    elsif Schedule.where(id: params[:schedule_id]).nil?
      render :status => :not_found, :json => {:errors => ["Schedule not found"]}
    else
      assignment = SelfAssignShiftService.call(params, current_user)
      if !assignment.nil?
        render :json => assignment
      else
        render :status => :unprocessable_entity, json: { errors: ["Could not assign shift"] }
      end
    end
  end


  def remove_from_schedule
    shift = Shift.where(id: params[:id]).first
    errors = Array.new
    if shift.user_scheduled && ((shift.start_time - DateTime::now).to_i / 1.day) > 4
      Shift.delete_by(id: shift.id)
      return render json: shift
    else
      unless shift.user_scheduled
        errors.push("Not scheduled by this user!")
      end
      unless ((shift.start_time - DateTime::now).to_i / 1.day) > 4
        errors.push("Starts in less than 4 days!")
      end
    end
    render :status => :unprocessable_entity, :json => {:errors => errors}
  end

  def get_possible_schedules
    shift = ShiftTemplate.where(id: params[:id]).first
    if shift.nil?
      render :status => :not_found, json: {:errors => ["Shift template not found!"]}
    else
      schedules = Schedule.where(id: Contract::active_agreements::where(employee_id: current_user.id).map { |c| c.schedule_id })
      render json: {:schedules => schedules}
    end
  end
end
