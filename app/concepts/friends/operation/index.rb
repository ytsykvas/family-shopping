# frozen_string_literal: true

class Friends::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! Friendship, :index?

    friendships = policy_scope(Friendship).accepted.includes(:requester, :accepter)
    friends = friendships.map do |friendship|
      friendship.requester_id == current_user.id ? friendship.accepter : friendship.requester
    end
    friendship_requests = policy_scope(Friendship).pending.includes(:requester, :accepter)

    self.model = OpenStruct.new(
      friends: friends,
      friendship_requests: friendship_requests,
      current_user: current_user
    )
  end
end
