# frozen_string_literal: true

class Users::Component::FriendshipStatus < Base::Component::Base
  def initialize(is_friend:, incoming_request:, outgoing_request:, is_own_profile:, **)
    @is_friend = is_friend
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

  def show_status?
    !is_own_profile? && (is_friend? || has_incoming_request? || has_outgoing_request?)
  end
end
