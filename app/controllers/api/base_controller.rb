# frozen_string_literal: true

module Api
  # Base controller for API endpoints
  # Provides JWT authentication and JSON responses
  class BaseController < ActionController::API
    include Pundit::Authorization

    before_action :authenticate_user_from_token!

    rescue_from Pundit::NotAuthorizedError, with: :render_unauthorized
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    private

    # Authenticate user from JWT token in Authorization header
    def authenticate_user_from_token!
      token = request.headers["Authorization"]&.split(" ")&.last
      return render_unauthorized unless token

      begin
        jwt_payload = JWT.decode(token, devise_jwt_secret, true, { algorithm: "HS256" }).first
        @current_user = User.find(jwt_payload["sub"])
      rescue JWT::ExpiredSignature
        render json: { error: "Token has expired" }, status: :unauthorized
      rescue JWT::DecodeError
        render json: { error: "Invalid token" }, status: :unauthorized
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found" }, status: :unauthorized
      end
    end

    # Override current_user for Pundit
    def current_user
      @current_user
    end

    def render_unauthorized
      render json: { error: "You are not authorized to perform this action" }, status: :forbidden
    end

    def render_not_found
      render json: { error: "Record not found" }, status: :not_found
    end

    def devise_jwt_secret
      Rails.application.credentials.devise_jwt_secret_key || ENV["DEVISE_JWT_SECRET_KEY"]
    end
  end
end
