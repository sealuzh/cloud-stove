class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :authenticate_user!, unless: :devise_controller?

  protected

    def authenticate_user!
      if user_signed_in?
        super
      else
        unauthorized_response
      end
    end

    def unauthorized_response
      respond_to do |format|
        format.html { flash[:error] = 'Only registered users are allowed to perform this action.'; redirect_to new_user_session_path }
        format.json { render json: { errors: ['Authorized users only.'] }, status: :unauthorized }
      end
    end

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

    def json_request?
      request.format.json?
    end
end
