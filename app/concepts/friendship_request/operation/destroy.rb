# frozen_string_literal: true

class FriendshipRequest::Operation::Destroy < Base::Operation::Base
  def perform!(params:, current_user:)
    friendship = Friendship.find(params[:id])

    unless friendship.requester_id == current_user.id || friendship.accepter_id == current_user.id
      authorize! friendship, :destroy?
      add_error(:base, I18n.t("friendship_requests.destroy.not_authorized"))
      invalid!
      self.redirect_path = "/friends"
      return
    end

    unless friendship.pending?
      authorize! friendship, :destroy?
      add_error(:base, I18n.t("friendship_requests.destroy.not_pending"))
      invalid!
      self.redirect_path = "/friends"
      return
    end

    authorize! friendship, :destroy?

    friendship.destroy!

    self.model = friendship
    self.redirect_path = "/friends"
    notice I18n.t("friendship_requests.destroy.success")
  end
end
