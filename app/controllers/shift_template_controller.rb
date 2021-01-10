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
      templates = ShiftTemplate.where(scheduling_unit_id: params[:unit_id]).all
      render :json => {:data => templates}
    end
  end
end
