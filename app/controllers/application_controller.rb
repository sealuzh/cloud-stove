class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  # Never redirect to sign in page for JSON API
  before_filter :require_login, unless: :json_request?

  private

    def authenticate_admin!
      unless current_user.try(:is_admin?)
        forbidden_response
      end
    end

    def forbidden_response
      respond_to do |format|
        format.html { flash[:error] = 'Only admin users are allowed to perform this action.'; redirect_to :back }
        format.json { render json: { errors: ['Authorized admins only.'] }, status: :forbidden }
      end
    end

    def require_login
      redirect_to new_user_session_url unless (devise_controller? || user_signed_in?)
    end

    def json_request?
      request.format.json?
    end
end
