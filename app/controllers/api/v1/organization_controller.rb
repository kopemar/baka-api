module Api
  module V1
    class OrganizationController < ApplicationController
      def get_employees
        permitted = params.permit(:id)
        organization = Organization.where(id: permitted[:id]).first
        return render :status => :not_found, :json => {:errors => ["Invalid Organization ID"]} if organization.nil?

        render :json => {:employees => Employee.where(organization_id: organization.id).order("last_name, first_name ASC").as_json(:only => [:id, :first_name, :last_name, :organization_id, :username, :uid])}
      end

      def create
        params.require([:name, :username, :password, :email, :first_name, :last_name])

        organization = Organization.create!(name: params[:name])

        user_by_uid = User.find_by_uid(params[:email])
        return render :status => :conflict, :json => {:errors => ["Could not create user with this email"], :success => false} unless user_by_uid.nil?

        user_by_username = User.find_by_username(params[:username])
        return render :status => :conflict, :json => {:errors => ["Could not create user with this username"], :success => false} unless user_by_username.nil?

        Manager.create!(organization_id: organization.id, username: params[:username], password: params[:password], uid: params[:email], email: params[:email], first_name: params[:first_name], last_name: params[:last_name])

        5.times do |i|
          SchedulingPeriod.create!(organization: organization, start_date: i.weeks.after(Date.today.monday), end_date: i.weeks.after(Date.today.sunday))
        end
        render :json => {:data => organization, :success => true}, :status => :created
      end
    end
  end
end
