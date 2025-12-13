class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :name, presence: true

  def jwt_payload
    {
      "sub" => id.to_s,
      "email" => email,
      "jti" => SecureRandom.uuid,
      "exp" => 24.hours.from_now.to_i
    }
  end
end
