class EmployeeController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_user!
  # todo cancan manager
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
      render json: { data: e, success: true }, status: :created
    else
      render json: { errors: errors, success: false }, status: :unprocessable_entity
    end
  end

  def index
    render json: Employee.accessible_by(current_ability)
  end

  def show
    params.require(:id)
    render json: {:data => Employee.find(params[:id])}
  end

  def specializations
    params.require(:id)
    employee = Employee.accessible_by(current_ability).find(params[:id])
    render json: { data: employee.specializations }
  end

  def contracts
    params.require(:id)
    employee = Employee.accessible_by(current_ability).find(params[:id])
    render json: { data: employee.contracts }
  end

  def shifts
    params.require(:id)
    params.permit(:upcoming)

    @shifts = Shift.filter(shift_filtering_params(params)).where(schedule: Schedule.where(contract: Contract.where(employee_id: params[:id]))).sort_by(&:start_time)

    render json: {:data => @shifts}
  end

  private

  # A list of the param names that can be used for filtering the S list
  def shift_filtering_params(params)
    params.slice(:upcoming)
  end
end
