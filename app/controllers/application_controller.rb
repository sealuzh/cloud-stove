class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  # Never redirect on for JSON API
  before_filter :require_login, unless: :json_request?

  private

    def require_login
      redirect_to new_user_session_url unless (devise_controller? || user_signed_in?)
    end

    def json_request?
      request.format.json?
    end
end
