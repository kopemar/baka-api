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
end
