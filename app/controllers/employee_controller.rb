class EmployeeController < ApplicationController
  def get_all
    logger.info json: Employee::with_employment_contract
    render json: Employee.all
  end
end
