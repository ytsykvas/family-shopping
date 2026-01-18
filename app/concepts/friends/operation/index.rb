# frozen_string_literal: true

class Friends::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! Friendship, :index?

    friendships = policy_scope(Friendship).accepted.includes(:requester, :accepter)
    friends = friendships.map do |friendship|
      friendship.requester_id == current_user.id ? friendship.accepter : friendship.requester
    end

    pending_requests = policy_scope(Friendship).pending.includes(:requester, :accepter)
    incoming_requests = pending_requests.where(accepter_id: current_user.id)
    outgoing_requests = pending_requests.where(requester_id: current_user.id)

    self.model = OpenStruct.new(
      friends: friends,
      friendships: friendships,
      friendship_requests: pending_requests,
      incoming_requests: incoming_requests,
      outgoing_requests: outgoing_requests,
      current_user: current_user
    )
  end
end
