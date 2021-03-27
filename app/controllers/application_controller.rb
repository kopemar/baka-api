class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_headers

  def set_headers
    response.headers["Expires"]='Mon, 01 Jan 2000 00:00:00 GMT'

    response.headers["Cache-Control"]="public, max_age=84600"
    response.headers["Last-Modified"]=Time.now.strftime("%a, %d %b %Y %T %Z")
  end

  def render_not_found_response(exception)
    render json: { error: exception.message }, status: :not_found
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email, :password, :first_name, :last_name, :password_confirmation])
  end

end