# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include OperationsMethods

  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :verify_authorized, unless: :devise_controller?
  after_action :verify_policy_scoped, if: -> { action_name == "index" && !devise_controller? }

  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referer || root_path)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :nickname ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :nickname ])
  end

  allow_browser versions: :modern
end
