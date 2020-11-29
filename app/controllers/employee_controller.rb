class EmployeeController < ApplicationController
  def get_all
    render json: Employee::with_employment_contract
  end
end
