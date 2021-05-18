module Api
  module V1
    class EmployeeController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken

      before_action :authenticate_user!

      def create
        params.require([:first_name, :last_name, :username, :username, :birth_date, :password, :email])
        params_hash = params.permit(:first_name, :last_name, :username, :username, :birth_date, :password, :email)

        user_by_uid = User.find_by_uid(params[:email])
        return render status: :conflict, json: {errors: ["Could not create user with this email"], success: false} unless user_by_uid.nil?

        user_by_username = User.find_by_username(params[:username])
        return render status: :conflict, json: {errors: ["Could not create user with this username"], success: false} unless user_by_username.nil?

        employee = Employee.new(params_hash.merge({organization_id: current_user.organization_id, uid: params[:email]}))

        if employee.save!
          e = Employee.find_by_username(params[:username])
          render json: {data: e, success: true}, status: :created
        else
          render json: {errors: errors, success: false}, status: :unprocessable_entity
        end
      end

      def index
        params.permit(:working_now, :page, :per_page)
        employees = Employee.filter(filtering_params(params)).accessible_by(current_ability).order("last_name")

        render json: {
            data: @collection = employees.paginate(page: params[:page], per_page: params[:per_page].nil? ? 15 : params[:per_page]),
            current_page: @collection.current_page,
            total_pages: @collection.total_pages,
            has_next: @collection.next_page.present?,
            records: employees.length
        }
      end

      def show
        params.require(:id)
        render json: {:data => Employee.find(params[:id])}
      end

      def specializations
        params.require(:id)
        employee = Employee.accessible_by(current_ability).find(params[:id])
        render json: {data: employee.specializations}
      end

      def contracts
        params.require(:id)
        employee = Employee.accessible_by(current_ability).find(params[:id])
        render json: {data: employee.contracts}
      end

      def shifts
        params.require(:id)
        params.permit(:upcoming)

        @shifts = Shift.filter(filtering_params(params)).where(schedule: Schedule.where(contract: Contract.where(employee_id: params[:id]))).sort_by(&:start_time)

        render json: {:data => @shifts}
      end

      private

      # A list of the param names that can be used for filtering the S list
      def filtering_params(params)
        params.slice(:working_now, :upcoming)
      end
    end
  end
end
