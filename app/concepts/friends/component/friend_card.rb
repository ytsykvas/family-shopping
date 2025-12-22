# frozen_string_literal: true

class Friends::Component::FriendCard < Base::Component::Base
  def initialize(friendship:, current_user:)
    @friendship = friendship
    @current_user = current_user
  end

  def friend
    if @friendship.requester_id == @current_user.id
      @friendship.accepter
    else
      @friendship.requester
    end
  end
end
