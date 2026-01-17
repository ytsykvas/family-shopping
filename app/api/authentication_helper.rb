module AuthenticationHelper
  def authenticate_user!
    token = headers["Authorization"]&.split(" ")&.last

    unless token
      error!({ error: "Missing authentication token" }, 401)
    end

    begin
      jwt_payload = JWT.decode(token, devise_jwt_secret, true, { algorithm: "HS256" }).first
      @current_user = User.find(jwt_payload["sub"])
    rescue JWT::ExpiredSignature
      error!({ error: "Token has expired" }, 401)
    rescue JWT::DecodeError
      error!({ error: "Invalid token" }, 401)
    rescue ActiveRecord::RecordNotFound
      error!({ error: "User not found" }, 401)
    end
  end

  def current_user
    @current_user
  end

  def devise_jwt_secret
    Devise::JWT.config.secret
  end

  def authorize!(record, query)
    policy = Pundit.policy!(current_user, record)
    unless policy.public_send(query)
      error!({ error: "You are not authorized to perform this action" }, 403)
    end
  end

  def policy_scope(scope)
    Pundit.policy_scope!(current_user, scope)
  end

  # Run operation and return its model as JSON
  def run_operation(operation_class)
    result = operation_class.call(params: params, current_user: current_user)
    result.model
  end
end
