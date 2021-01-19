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
          start_time: params[:start_time].to_datetime, end_time: params[:end_time].to_datetime, break_minutes: params[:break_minutes].to_i)
      render :json => {:data => template}
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
    render :json => {:data => templates}
  end

  def get_unassigned_shifts
    overlaps = Shift::for_user(current_user).map { |d| "end_time >= '#{d.start_time}' AND start_time <= '#{d.end_time}'" }.join(" OR ")
    if params[:start_date].nil? && params[:end_date].nil?
      if overlaps.empty?
        ShiftTemplate.all.order('start_time')
      else
        ShiftTemplate.where.not(overlaps).order('start_time')
      end
    elsif params[:start_date].nil?
      if overlaps.empty?
        ShiftTemplate::planned_before(params[:end_date].to_datetime).all.order('start_time DESC')
      else
        ShiftTemplate::planned_before(params[:end_date].to_datetime).where.not(overlaps).order('start_time DESC')
      end
    elsif params[:end_date].nil?
      if overlaps.empty?
        ShiftTemplate::planned_after(params[:start_date].to_datetime).all.order('start_time')
      else
        ShiftTemplate::planned_after(params[:start_date].to_datetime).where.not(overlaps).order('start_time')
      end
    else
      if overlaps.empty?
        ShiftTemplate::planned_between(params[:start_date].to_datetime, params[:end_date].to_datetime).order('start_time')
      else
        ShiftTemplate::planned_between(params[:start_date].to_datetime, params[:end_date].to_datetime).where.not(overlaps).order('start_time')
      end
    end
  end
end
