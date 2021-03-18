class UserController < ApplicationController
  before_action :authenticate_user!
  def save_fcm_token
    params.require(:fcm_token)
    current_user.fcm_token.push(params[:fcm_token])
    current_user.save!

    render :json => { :success => true }
  end
end
