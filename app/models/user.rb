class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :name, presence: true
  validates :nickname, presence: true, uniqueness: { case_sensitive: false }

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:email))
      where(conditions.to_h).where([ "lower(email) = :value OR lower(nickname) = :value", { value: login.downcase } ]).first
    elsif conditions.has_key?(:email) || conditions.has_key?(:nickname)
      where(conditions.to_h).first
    end
  end

  def jwt_payload
    {
      "sub" => id.to_s,
      "email" => email,
      "jti" => SecureRandom.uuid,
      "exp" => 24.hours.from_now.to_i
    }
  end
end
