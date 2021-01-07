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
    if params[:schedule_id].nil?
      return render :status => :bad_request, :json => {:errors => ["schedule_id not defined"]}
    end
    contract = Contract::active_agreements.where(employee_id: current_user.id).where(schedule_id: params[:schedule_id]).first
    shift = Shift.where(id: params[:id]).first
    errors = Array.new
    if shift.nil?
      render :status => :not_found, json: {:errors => {
          :message => "Shift not found!"
      }}
    elsif !contract.nil?
      if shift.schedule_id.nil?
        shift.schedule_id = contract.schedule_id
        shift.user_scheduled = true
        if shift.save!
          return render json: shift
        else
          errors.push("Could not save shift")
        end
      else
        errors.push("Schedule ID is not nil")
      end
    end
    render :status => :unprocessable_entity, :json => {:errors => errors}
  end

  def get_unassigned_shifts
    overlaps = Shift.where(schedule_id: Schedule.where(contract_id: Contract.where(employee_id: current_user.id).all.map { |d| d.id })).map { |d| "end_time >= '#{d.start_time}' AND start_time <= '#{d.end_time}'" }.join(" OR ")
    if params[:start_date].nil? && params[:end_date].nil?
      if overlaps.empty?
        Shift::unassigned.all.order('shifts.start_time')
      else
        Shift::unassigned.where.not(overlaps).order('shifts.start_time')
      end
    elsif params[:start_date].nil?
      if overlaps.empty?
        Shift::unassigned::planned_before(params[:end_date].to_datetime).all.order('shifts.start_time DESC')
      else
        Shift::unassigned::planned_before(params[:end_date].to_datetime).where.not(overlaps).order('shifts.start_time DESC')
      end
    elsif params[:end_date].nil?
      if overlaps.empty?
        Shift::unassigned::planned_after(params[:start_date].to_datetime).all.order('shifts.start_time')
      else
        Shift::unassigned::planned_after(params[:start_date].to_datetime).where.not(overlaps).order('shifts.start_time')
      end
    else
      if overlaps.empty?
        Shift::unassigned::planned_between(params[:start_date].to_datetime, params[:end_date].to_datetime).order('shifts.start_time')
      else
        Shift::unassigned::planned_between(params[:start_date].to_datetime, params[:end_date].to_datetime).where.not(overlaps).order('shifts.start_time')
      end
    end
  end

  def remove_from_schedule
    shift = Shift.where(id: params[:id]).first
    errors = Array.new
    if shift.user_scheduled && ((shift.start_time - DateTime::now).to_i / 1.day) > 4
      shift.schedule_id = nil
      shift.save!
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
    shift = Shift.where(id: params[:id]).first
    if shift.nil?
      render :status => :not_found, json: {:errors => ["Shift not found!"]}
    else
      schedules = Schedule.where(id: Contract::active_agreements::where(employee_id: current_user.id).map { |c| c.schedule_id })
      render json: {:schedules => schedules}
    end
  end
end
