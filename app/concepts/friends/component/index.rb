# frozen_string_literal: true

class Friends::Component::Index < Base::Component::Base
  def initialize(friends:, friendship_requests:, current_user: nil)
    @friends = friends
    @friendship_requests = friendship_requests
    @current_user = current_user
  end
end
