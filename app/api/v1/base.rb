class V1::Base < Grape::API
  version "v1", using: :path

  helpers AuthenticationHelper

  before do
    authenticate_user! unless route.settings[:public]
  end

  mount V1::Users
end
