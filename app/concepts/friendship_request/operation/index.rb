# frozen_string_literal: true

class FriendshipRequest::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! Friendship, :index?

    self.model = policy_scope(Friendship).pending.includes(:requester, :accepter)
  end
end
