# frozen_string_literal: true

class Api::Users::Operation::CheckEmail < Base::Operation::Base
  def perform!(params:, current_user:)
    skip_authorize
    skip_policy_scope

    email = params[:email]

    unless email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
      self.model = { available: false, message: I18n.t("api.users.email_invalid") }
      return
    end

    exists = User.where("lower(email) = ?", email.downcase).exists?

    self.model = if exists
                   { available: false, message: I18n.t("api.users.email_taken") }
    else
                   { available: true, message: I18n.t("api.users.email_available") }
    end
  end
end
