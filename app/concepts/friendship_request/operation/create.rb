# frozen_string_literal: true

class FriendshipRequest::Operation::Create < Base::Operation::Base
  def perform!(params:, current_user:)
    friendship_params = friendship_request_params(params)
    accepter_id = friendship_params[:accepter_id]
    accepter = User.find(accepter_id)

    if current_user.id == accepter.id
      add_error(:base, I18n.t("friendship_requests.create.cannot_request_self"))
      invalid!
      self.redirect_path = "/friends"
      return
    end

    existing_friendship = Friendship.between_users(current_user, accepter).first
    if existing_friendship.present?
      add_error(:base, I18n.t("friendship_requests.create.already_exists"))
      invalid!
      self.redirect_path = "/friends"
      return
    end

    friendship = Friendship.new(
      requester: current_user,
      accepter: accepter,
      status: :pending,
      message: friendship_params[:message]
    )

    authorize! friendship, :create?

    friendship.save!

    self.model = friendship
    self.redirect_path = "/friends"
    notice I18n.t("friendship_requests.create.success")
  end

  private

  def friendship_request_params(params)
    if params.is_a?(ActionController::Parameters)
      params.require(:friendship_request).permit(:accepter_id, :message)
    else
      params.fetch(:friendship_request, {}).slice(:accepter_id, :message).with_indifferent_access
    end
  end
end
