# frozen_string_literal: true

class FriendshipRequest::Operation::Update < Base::Operation::Base
  def perform!(params:, current_user:)
    friendship = Friendship.find(params[:id])

    if friendship.accepter_id != current_user.id
      authorize! friendship, :update?
      add_error(:base, I18n.t("friendship_requests.update.not_accepter"))
      invalid!
      self.redirect_path = "/friends"
      return
    end

    unless friendship.pending?
      authorize! friendship, :update?
      add_error(:base, I18n.t("friendship_requests.update.not_pending"))
      invalid!
      self.redirect_path = "/friends"
      return
    end

    authorize! friendship, :update?

    friendship.update!(status: :accepted)

    self.model = friendship
    self.redirect_path = "/friends"
    notice I18n.t("friendship_requests.update.success")
  end
end
