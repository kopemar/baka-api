class EmployeeController < ApplicationController
  def get_all
    render json: Employee.create!
  end
end
