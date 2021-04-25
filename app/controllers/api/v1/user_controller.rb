module Api
  module V1
    class UserController < ApplicationController
      before_action :authenticate_user!

      def save_fcm_token
        params.require(:fcm_token)

        token = params[:fcm_token]
        uid = current_user.id
        client = request.headers["client"]

        FcmToken.create!(:fcm_token => token, :user_id => uid, :client => client)
        render :json => {:success => true}
      end

    end
  end
end