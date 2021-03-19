class OrganizationController < ApplicationController
  def get_employees
    permitted = params.permit(:id)
    organization = Organization.where(id: permitted[:id]).first
    return render :status => :not_found, :json => {:errors => ["Invalid Organization ID"]} if organization.nil?

    # todo pagination
    render :json => {:assigned_employees => Employee.where(organization_id: organization.id).order("last_name, first_name ASC").as_json(:only => [:id, :first_name, :last_name, :organization_id, :username])  }
  end
end
