class V1::Users < Grape::API
  resource :users do
    desc "Check if nickname is available",
         tags: [ "Users" ],
         detail: "Returns whether the nickname is available for registration",
         success: Entities::AvailabilityResponse
    params do
      requires :nickname, type: String, desc: "Nickname to check", documentation: { example: "john_doe" }
    end
    route_setting :public, true
    get :check_nickname do
      result = run_operation Api::Users::Operation::CheckNickname
      present result, with: Entities::AvailabilityResponse
    end

    desc "Check if email is available",
         tags: [ "Users" ],
         detail: "Returns whether the email is available for registration",
         success: Entities::AvailabilityResponse
    params do
      requires :email, type: String, desc: "Email to check", documentation: { example: "user@example.com" }
    end
    route_setting :public, true
    get :check_email do
      result = run_operation Api::Users::Operation::CheckEmail
      present result, with: Entities::AvailabilityResponse
    end
    route_param :id do
      desc "Get a user",
           tags: [ "Users" ],
           success: Entities::User
      get do
        result = run_operation ::Users::Operation::Show
        present result.user, with: Entities::User
      end
    end
  end
end
