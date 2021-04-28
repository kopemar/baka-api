module Api
  module V1
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

        @templates = ShiftTemplate.filter(filtering_params(params)).accessible_by(current_ability, :read)

        if params[:unassigned] && !current_user.manager?
          exclude = Shift::for_user(current_user).map { |d| "shift_templates.end_time >= '#{12.hours.before(d.start_time)}' AND shift_templates.start_time <= '#{12.hours.after(d.end_time)}'" }.join(" OR ")
          unless exclude.nil? || exclude.empty?
            logger.debug "exclude #{exclude}"
            @templates =  @templates.where.not(exclude)
          end
        end

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

        template = ShiftTemplate.find(params[:id])

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

        specializations = Specialization.joins(:organization).where(organizations: {id: current_user.organization_id})

        render :json => {data: specializations}
      end

      def employees
        params.require(:id)
        params.permit(:id)
        template = ShiftTemplate.find(params[:id])
        return render :status => :bad_request, :json => {:errors => ["No ID"]} if template.nil?

        render :json => {:employees => Contract.where(schedule_id: Shift.where(shift_template_id: template.id).map(&:schedule_id)).map(&:employee).as_json(:only => [:id, :first_name, :last_name, :username, :uid])}
      end

      def filtering_params(params)
        params.slice(:unit, :unassigned)
      end
    end
  end
end
