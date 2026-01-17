# frozen_string_literal: true

class FriendshipRequest::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! Friendship, :index?

    requests = policy_scope(Friendship).pending.includes(:requester, :accepter)
    incoming = requests.where(accepter: current_user)
    outgoing = requests.where(requester: current_user)

    self.model = OpenStruct.new(
      incoming_requests: incoming,
      outgoing_requests: outgoing
    )
  end
end
