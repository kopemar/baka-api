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
    shifts = Shift.where(schedule: Schedule.where(contract: Contract.where(employee_id: params[id])))

    render json: { :data => shifts }
  end
end
