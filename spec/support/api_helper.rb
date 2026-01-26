require 'devise/jwt/test_helpers'

module ApiHelper
  def auth_headers(user)
    headers = { "Accept" => "application/json", "Content-Type" => "application/json" }
    Devise::JWT::TestHelpers.auth_headers(headers, user)
  end

  def json
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include ApiHelper, type: :request
end
