class EmployeeController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_user!

  def create
    params.require([:first_name, :last_name, :username, :username, :birth_date, :password, :email])
    params_hash = params.permit(:first_name, :last_name, :username, :username, :birth_date, :password, :email)

    user_by_uid = User.find_by_uid(params[:email])
    return render :status => :conflict, :json => {:errors => ["Could not create user with this email"], :success => false} unless user_by_uid.nil?

    user_by_username = User.find_by_username(params[:username])
    return render :status => :conflict, :json => {:errors => ["Could not create user with this username"], :success => false} unless user_by_username.nil?

    employee = Employee.create!(params_hash.merge({organization_id: current_user.organization_id}))

    render json: { data: employee }, status: :created
  end

  def get_all
    render json: Employee.all
  end

  def get_by_id
    params.require(:id)
    render json: {:data => Employee.where(id: params[:id]).first}
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
