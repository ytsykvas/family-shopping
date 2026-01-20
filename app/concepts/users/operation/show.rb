# frozen_string_literal: true

class Users::Operation::Show < Base::Operation::Base
  def perform!(params:, current_user:)
    user = User.find(params[:id])
    authorize! user, :show?

    friendship = Friendship.between_users(current_user, user).first
    is_friend = friendship&.accepted?

    incoming_request = Friendship.pending.find_by(requester: user, accepter: current_user)
    outgoing_request = Friendship.pending.find_by(requester: current_user, accepter: user)

    self.model = OpenStruct.new(
      user: user,
      current_user: current_user,
      is_friend: is_friend,
      friendship: friendship,
      incoming_request: incoming_request,
      outgoing_request: outgoing_request
    )
  end
end
