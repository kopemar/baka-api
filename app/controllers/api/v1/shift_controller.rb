module Api
  module V1
    class ShiftController < ApplicationController
      before_action :authenticate_user!

      def index
        params.permit(:past, :upcoming)

        schedule = Shift.filter(shift_filtering_params(params)).where(schedule: Schedule.where(contract: Contract.where(employee_id: current_user.id))).submitted.order('start_time')

        render json: {
            :shifts => @collection = schedule.paginate(page: params[:page], per_page: params[:per_page].nil? ? 30 : params[:per_page]),
            :current_page => @collection.current_page,
            :total_pages => @collection.total_pages,
            :has_next => @collection.next_page.present?
        }
      end

      def create
        ActiveRecord::Base.transaction do
          params.require(:template_id)
          params.permit(:template_id, :schedule_id, :schedules)
          @template = ShiftTemplate.accessible_by(current_ability).find(params[:template_id])

          if !params[:schedule_id].nil? && Schedule.find(params[:schedule_id]).nil?
            render :status => :not_found, :json => {:errors => ["Schedule not found"]}
          elsif current_user.manager? && !params[:schedules].nil?
            params.require(:schedules)
            @shifts = []
            params[:schedules].to_a.each do |id|
              @schedule = Schedule.accessible_by(current_ability).find(id)
              shift = Shift.from_template(@template)
              shift.schedule_id = @schedule.id
              shift.scheduler_type = SCHEDULER_TYPES[:MANAGER]
              shift.save!
              @shifts.push(shift)
            end
            return render :status => :ok, :json => {data: @shifts}
          else
            assignment = SelfAssignShiftService.call(params, current_user)
            if !assignment.nil?
              render :json => assignment
            else
              render :status => :unprocessable_entity, json: {errors: ["Could not assign shift"]}
            end
          end
        end
      end

      def destroy
        params.permit(:id)
        shift = Shift.accessible_by(current_ability, :destroy).find(params[:id].to_i)
        Shift.delete_by(id: shift.id)
        return render json: {success: true}
      end

      def get_possible_schedules
        shift = ShiftTemplate.find(params[:id])
        if shift.nil?
          render :status => :not_found, json: {:errors => ["Shift template not found!"]}
        elsif current_user.manager?
          forbidden_ids = Shift.where("shifts.start_time >= ? AND shifts.end_time <= ?", MINIMUM_BREAK_HOURS_UNDERAGE.hours.before(shift.start_time), MINIMUM_BREAK_HOURS_UNDERAGE.hours.after(shift.end_time)).map(&:schedule_id)

          schedules = Schedule
                          .accessible_by(current_ability)
                          .where
                          .not(id: forbidden_ids)
                          .where(contract_id: Contract.active_employment_contracts.map(&:id))
                          .as_json(:only => [:id, :first_name, :last_name])
          render json: {:data => schedules, :success => true }
        else
          schedules = Schedule.where(id: Contract::active_agreements::where(employee_id: current_user.id).map { |c| c.schedule_id })
          render json: {:data => schedules}
        end
      end

      def shift_filtering_params(params)
        params.slice(:upcoming)
      end
    end
  end
end