class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Override jwt_payload to include custom claims
  def jwt_payload
    super.merge("email" => email)
  end
end
