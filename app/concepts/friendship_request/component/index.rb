# frozen_string_literal: true

class FriendshipRequest::Component::Index < Base::Component::Base
  def initialize(friendship_requests:, current_user: nil)
    @friendship_requests = friendship_requests
    @current_user = current_user
  end
end
