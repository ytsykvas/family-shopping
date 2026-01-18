class V1::Sessions < Grape::API
  resource :sessions do
    desc "Authenticate user and return JWT token",
         tags: [ "Authentication" ],
         success: Entities::Token
    params do
      optional :email, type: String, desc: "User email", documentation: { param_type: "formData", example: "user@example.com" }
      optional :nickname, type: String, desc: "User nickname", documentation: { param_type: "formData", example: "john_doe" }
      requires :password, type: String, desc: "User password", documentation: { param_type: "formData", example: "password" }
      at_least_one_of :email, :nickname
    end
    route_setting :public, true
    post :login do
      user = nil
      if params[:email].present?
        user = User.find_by("lower(email) = ?", params[:email].downcase)
      elsif params[:nickname].present?
        user = User.find_by("lower(nickname) = ?", params[:nickname].downcase)
      end

      if user&.valid_password?(params[:password])
        token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
        present({ token: token, user_id: user.id, email: user.email }, with: Entities::Token)
      else
        error!({ error: "Invalid login credentials" }, 401)
      end
    end
  end
end
