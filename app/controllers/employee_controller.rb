class EmployeeController < ApplicationController
  def get_all
    render json: Employee.all
  end

  def get_by_id
    params.require(:id)
    render json: { :data => Employee.where(id: params[:id]).first }
  end

  def shifts
    params.require(:id)
    params.permit(:upcoming)

    @shifts = Shift.filter(shift_filtering_params(params)).where(schedule: Schedule.where(contract: Contract.where(employee_id: params[:id]))).sort_by(&:start_time)

    render json: { :data => @shifts }
  end

  private

  # A list of the param names that can be used for filtering the S list
  def shift_filtering_params(params)
    params.slice(:upcoming)
  end
end
