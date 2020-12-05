class ContractController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken

  def get_all
    render json: Contract::active_employment_contracts
  end

  # before_action :authenticate_user!
  def get_current_user_contracts
    render json: Contract.where(employee_id: current_user.id)
  end
end
