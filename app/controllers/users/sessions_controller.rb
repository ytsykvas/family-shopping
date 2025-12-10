# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    respond_to :json

    private

    # Override respond_with to handle both HTML and JSON responses
    def respond_with(resource, _opts = {})
      if request.format.json?
        render json: {
          status: { code: 200, message: "Logged in successfully." },
          data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
        }, status: :ok
      else
        super
      end
    end

    def respond_to_on_destroy
      if request.format.json?
        if current_user
          render json: {
            status: 200,
            message: "Logged out successfully."
          }, status: :ok
        else
          render json: {
            status: 401,
            message: "Couldn't find an active session."
          }, status: :unauthorized
        end
      else
        super
      end
    end
  end
end
