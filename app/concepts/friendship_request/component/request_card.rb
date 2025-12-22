# frozen_string_literal: true

class FriendshipRequest::Component::RequestCard < Base::Component::Base
  def initialize(friendship_request:, current_user:)
    @friendship_request = friendship_request
    @current_user = current_user
  end

  def is_incoming_request?
    @current_user && @friendship_request.accepter_id == @current_user.id
  end

  def request_user
    is_incoming_request? ? @friendship_request.requester : @friendship_request.accepter
  end
end
