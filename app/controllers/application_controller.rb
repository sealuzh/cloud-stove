class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_filter :require_login, unless: :devise_controller?

  private

    def require_login
      redirect_to new_user_session_url unless user_signed_in?
    end
end
