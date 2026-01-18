# frozen_string_literal: true

class Friends::Component::Index < Base::Component::Base
  def initialize(friendships:, incoming_requests:, outgoing_requests:, current_user: nil)
    @friendships = friendships
    @incoming_requests = incoming_requests
    @outgoing_requests = outgoing_requests
    @current_user = current_user
  end
end
