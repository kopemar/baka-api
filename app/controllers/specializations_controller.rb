class SpecializationsController < ApplicationController
  before_action :authenticate_user!

  # GET /specializations
  def index

    unless current_user.is_manager?
      return render :status => :forbidden
    end
    @specializations = Specialization.where(organization_id: current_user.organization_id)

    render :json => { :data => @specializations }
  end

  # POST /specializations
  def create
    params.require(:name)
    unless current_user.is_manager?
      return render :status => :forbidden
    end

    @specialization = Specialization.new(name: params[:name], organization_id: current_user.organization_id)

    if @specialization.save
      render json: @specialization, status: :created, location: @specialization
    else
      render json: @specialization.errors, status: :unprocessable_entity
    end
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
end
