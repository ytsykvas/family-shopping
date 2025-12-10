class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = "jwt_denylists"

  # Clean up expired tokens periodically
  def self.cleanup_expired
    where("exp < ?", Time.current).delete_all
  end
end
