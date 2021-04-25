module Api
  module V1
    class ContractController < ApplicationController
      include DeviseTokenAuth::Concerns::SetUserByToken

      before_action :authenticate_user! #, load_and_authorize_resource

      def get_all
        render json: Contract::active_employment_contracts
      end

      def create
        params.require([:start_date, :employee_id, :type])
        params_hash = params.permit(:start_date, :end_date, :work_load, :employee_id, :type)

        return render json: {success: false, data: nil}, status: :forbidden if Employee.where(id: params[:employee_id]).accessible_by(current_ability).empty?
        contract = Contract.new(params_hash)

        Rails.logger.debug "🍬 #{contract}"
        if contract.save
          render json: {success: true, data: Contract.find(contract.id)}
        else
          render json: {success: false, data: nil}, status: :unprocessable_entity
        end
      end

      def index
        render json: {data: Contract.accessible_by(current_ability)}
      end
    end
  end
end