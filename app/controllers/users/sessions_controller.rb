# frozen_string_literal: true

class Users::SessionsController < DeviseTokenAuth::SessionsController

  # DELETE /resource/sign_out
  def destroy
    client = request.headers["client"]
    FcmToken.where(client: client).delete_all
    super
  end
end
