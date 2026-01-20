# frozen_string_literal: true

class Users::Component::Show < Base::Component::Base
  def initialize(user:, current_user:, is_friend:, friendship:, incoming_request:, outgoing_request:, **)
    @user = user
    @current_user = current_user
    @is_friend = is_friend
    @friendship = friendship
    @incoming_request = incoming_request
    @outgoing_request = outgoing_request
  end

  def is_own_profile?
    @user.id == @current_user.id
  end
end
