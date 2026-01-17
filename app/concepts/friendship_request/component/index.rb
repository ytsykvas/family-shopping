# frozen_string_literal: true

class FriendshipRequest::Component::Index < Base::Component::Base
  def initialize(incoming_requests:, outgoing_requests:, current_user: nil)
    @incoming_requests = incoming_requests
    @outgoing_requests = outgoing_requests
    @current_user = current_user
  end
end
