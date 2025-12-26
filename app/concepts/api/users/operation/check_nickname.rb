# frozen_string_literal: true

class Api::Users::Operation::CheckNickname < Base::Operation::Base
  def perform!(params:, current_user:)
    skip_authorize
    skip_policy_scope

    nickname = params[:nickname]
    exists = User.where("lower(nickname) = ?", nickname.downcase).exists?

    self.model = if exists
                   { available: false, message: I18n.t("api.users.nickname_taken") }
    else
                   { available: true, message: I18n.t("api.users.nickname_available") }
    end
  end
end
