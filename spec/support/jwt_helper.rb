# frozen_string_literal: true

module JwtHelper
  # Generate JWT token for testing
  def generate_jwt_token(user)
    payload = {
      sub: user.id,
      email: user.email,
      jti: SecureRandom.uuid,
      exp: 24.hours.from_now.to_i
    }

    JWT.encode(payload, jwt_secret, 'HS256')
  end

  # Decode JWT token for testing
  def decode_jwt_token(token)
    JWT.decode(token, jwt_secret, true, { algorithm: 'HS256' }).first
  end

  private

  def jwt_secret
    Rails.application.credentials.devise_jwt_secret_key || ENV['DEVISE_JWT_SECRET_KEY']
  end
end

RSpec.configure do |config|
  config.include JwtHelper, type: :controller
  config.include JwtHelper, type: :request
end
