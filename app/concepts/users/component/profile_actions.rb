# frozen_string_literal: true

class Users::Component::ProfileActions < Base::Component::Base
  def initialize(user:, is_friend:, friendship:, incoming_request:, outgoing_request:, is_own_profile:, **)
    @user = user
    @is_friend = is_friend
    @friendship = friendship
    @incoming_request = incoming_request
    @outgoing_request = outgoing_request
    @is_own_profile = is_own_profile
  end

  def is_friend?
    @is_friend
  end

  def has_incoming_request?
    @incoming_request.present?
  end

  def has_outgoing_request?
    @outgoing_request.present?
  end

  def is_own_profile?
    @is_own_profile
  end
end
