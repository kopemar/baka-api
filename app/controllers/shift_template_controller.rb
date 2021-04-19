class ShiftTemplateController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def create_specialized_template
    params.require([:id, :specialization_id])
    return render :status => :forbidden, :json => {:errors => ["Forbidden"]} unless current_user.manager?

    parent_template = ShiftTemplate::filter_by_organization(current_user.organization_id).where(id: params[:id]).first
    specialization = Specialization.where(id: params[:specialization_id]).first

    return render :status => :not_found if parent_template.nil? || specialization.nil? || !parent_template.specialization_id.nil?

    template = ShiftTemplate.create!(
        start_time: parent_template.start_time,
        end_time: parent_template.end_time,
        break_minutes: parent_template.break_minutes,
        priority: parent_template.priority,
        organization_id: current_user.organization_id,
        is_employment_contract: parent_template.is_employment_contract,
        parent_template_id: parent_template.id,
        specialization_id: specialization.id
    )

    render :status => :created, :json => template
  end

  def index
    params.permit(:unit, :unassigned)

    @templates = ShiftTemplate.filter(filtering_params(params)).filter_by_organization(current_user.organization_id)

    render :json => {:data => @templates}
  end

  # todo remove this
  def create
    params.require([:start_time, :end_time, :break_minutes, :priority])
    render :status => :forbidden, :json => {:errors => ["Forbidden"]} unless current_user.manager?

    template = ShiftTemplate.create!(
        start_time: params[:start_time].to_datetime,
        end_time: params[:end_time].to_datetime,
        break_minutes: params[:break_minutes].to_i,
        priority: params[:priority].to_i,
        organization_id: current_user.organization_id,
        is_employment_contract: false
    )
    render :json => {:data => template}
  end

  def update
    params.require(:id)
    permitted_params = params.permit(:priority)

    template = ShiftTemplate.where(id: params[:id]).first

    return render :status => :not_found if template.nil?

    priority = params[:priority]

    unless priority.nil?
      template.update! permitted_params
    end

    render :json => template
  end

  def get_specializations
    params.require(:id)

    return render :status => :forbidden unless current_user.manager?

    template = ShiftTemplate.where(id: params[:id]).first
    return render :status => :not_found if template.nil?
    return render :status => :unprocessable_entity unless template.specialization_id.nil?

    specializations = Specialization.joins(:organization).where(organizations: { id: current_user.organization_id })

    render :json => { data: specializations }
  end

  def get_employees
    template = ShiftTemplate.where(id: params["id"]).first
    return render :status => :bad_request, :json => {:errors => ["No ID"]} if template.nil?

    render :json => {:employees => Contract.where(schedule_id: Shift.where(shift_template_id: template.id).map(&:schedule_id)).map(&:employee).as_json(:only => [:id, :first_name, :last_name, :username])}
  end

  def get_unassigned_shifts
    # todo cleanup
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

  def filtering_params(params)
    params.slice(:unit)
  end
end
