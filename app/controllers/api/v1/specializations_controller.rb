module Api
  module V1
    class SpecializationsController < ApplicationController
      before_action :authenticate_user!

      # GET /specializations
      # Get all speci in scope of manager organization
      def index
        @specializations = Specialization.filter(filtering_params(params)).accessible_by(current_ability)

        render :json => {:data => @specializations}
      end

      # POST /specializations
      # Create new speci for current users' organization
      def create
        params.require(:name)
        @specialization = Specialization.new(name: params[:name], organization_id: current_user.organization_id)

        if @specialization.save
          render json: @specialization, status: :created, location: @specialization
        else
          render json: @specialization.errors, status: :unprocessable_entity
        end
      end

      def update
        params.require([:id, :employees])

        @specialization = Specialization.accessible_by(current_ability, :update).find(params[:id])
        return render :status => :not_found if @specialization.nil?

        contracts = Contract.where(id: params[:employees].map(&:to_i))

        contracts.each do |c|
          c.specializations.push(@specialization)
          c.save!
        end

        render :json => {data: @specialization}, :status => :ok
      end

      # Selects possible contracts (criteria: from organization && active && does not have this specialization )
      def get_possible_contracts
        params.require(:id)

        unless current_user.manager?
          return render :status => :forbidden
        end

        @specialization = Specialization.find(params[:id])
        return render :status => :not_found if @specialization.nil?

        contracts = Contract::active_employment_contracts.joins(:employee).where(users: {organization_id: current_user.organization_id}).left_joins(:specializations)

        render :json => {data: contracts.filter { |c| c.specializations.empty? || c.specializations.to_a.find { |s| s.id == params[:id].to_i }.nil? }}
      end

      def get_employees
        params.require(:id)

        unless current_user.manager?
          return render :status => :forbidden
        end

        @specialization = Specialization.accessible_by(current_ability, :update).find(params[:id])
        return render :status => :not_found if @specialization.nil?

        employees = Employee.accessible_by(current_ability).joins(:contracts).where(contracts: Contract.joins(:specializations).where(specializations: {id: params[:id]}))

        render :json => {:employees => employees}
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_specialization
        @specialization = Specialization.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def specialization_params
        params.fetch(:name, {})
      end

      def filtering_params(params)
        params.slice(:for_template)
      end
    end
  end
end
