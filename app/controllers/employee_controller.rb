class EmployeeController < ApplicationController
  def get_all
    render json: Employee.all
  end
end
