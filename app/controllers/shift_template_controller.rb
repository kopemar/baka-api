class ShiftTemplateController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def create_template
    if !current_user.is_manager?
      render :status => :forbidden, :json => {:errors => ["Forbidden"]}
    elsif params[:start_time].nil? || params[:end_time].nil? || params[:break_minutes].nil?
      return render :status => :unprocessable_entity, :json => {:errors => ["Something is missing"]}
    else
      template = ShiftTemplate.create!(
          start_time: params[:start_time].to_datetime,
          end_time: params[:end_time].to_datetime,
          break_minutes: params[:break_minutes].to_i,
          priority: params[:priority].to_i,
          organization_id: current_user.organization_id,
          is_employment_contract: false
      )
      render :json => {:templates => template}
    end
  end

  def in_unit
    if params[:unit_id].nil?
      render :status => :unprocessable_entity, :json => {:errors => ["Unit Id is missing"]}
    else
      ShiftTemplate.where(scheduling_unit_id: params[:unit_id]).all
    end
  end

  def get_templates
    templates = if params[:unit_id].nil?
      get_unassigned_shifts
    else
      in_unit
    end
    render :json => {:templates => templates}
  end

  def get_unassigned_shifts
    overlaps = Shift::for_user(current_user).map { |d| "end_time >= '#{d.start_time}' AND start_time <= '#{d.end_time}'" }.join(" OR ")
    if params[:start_date].nil? && params[:end_date].nil?
      if overlaps.empty?
        ShiftTemplate::can_be_user_scheduled.where(organization_id: current_user.organization_id).order('start_time')
      else
        ShiftTemplate::can_be_user_scheduled.where.not(overlaps).where(organization_id: current_user.organization_id).order('start_time')
      end
    elsif params[:start_date].nil?
      if overlaps.empty?
        ShiftTemplate::can_be_user_scheduled::planned_before(params[:end_date].to_datetime).where(organization_id: current_user.organization_id).order('start_time DESC')
      else
        ShiftTemplate::can_be_user_scheduled::planned_before(params[:end_date].to_datetime).where.not(overlaps).where(organization_id: current_user.organization_id).order('start_time DESC')
      end
    elsif params[:end_date].nil?
      if overlaps.empty?
        ShiftTemplate::can_be_user_scheduled::planned_after(params[:start_date].to_datetime).where(organization_id: current_user.organization_id).order('start_time')
      else
        ShiftTemplate::can_be_user_scheduled::planned_after(params[:start_date].to_datetime).where.not(overlaps).where(organization_id: current_user.organization_id).order('start_time')
      end
    else
      if overlaps.empty?
        ShiftTemplate::can_be_user_scheduled::planned_between(params[:start_date].to_datetime, params[:end_date].to_datetime).order('start_time').where(organization_id: current_user.organization_id)
      else
        ShiftTemplate::can_be_user_scheduled::planned_between(params[:start_date].to_datetime, params[:end_date].to_datetime).where.not(overlaps).where(organization_id: current_user.organization_id).order('start_time')
      end
    end
  end
end
