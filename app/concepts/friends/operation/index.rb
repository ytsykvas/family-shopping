# frozen_string_literal: true

class Friends::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! Friendship, :index?

    friends = policy_scope(Friendship).accepted.includes(:requester, :accepter)
    friendship_requests = policy_scope(Friendship).pending.includes(:requester, :accepter)

    self.model = OpenStruct.new(
      friends: friends,
      friendship_requests: friendship_requests,
      current_user: current_user
    )
  end
end
