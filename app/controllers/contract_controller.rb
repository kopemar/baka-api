class ContractController < ApplicationController
  def get_all
    render json: Contract::active_employment_contracts
  end
end
