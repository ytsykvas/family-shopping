# frozen_string_literal: true

class UserSearches::Component::ResultCard < Base::Component::Base
  def initialize(user:, friends_ids:, incoming_requests:, outgoing_requests:)
    @user = user
    @friends_ids = friends_ids
    @incoming_requests = incoming_requests
    @outgoing_requests = outgoing_requests
  end

  def is_friend?
    @friends_ids.include?(@user.id)
  end

  def has_incoming_request?
    @incoming_requests.key?(@user.id)
  end

  def incoming_request
    @incoming_requests[@user.id]
  end

  def has_outgoing_request?
    @outgoing_requests.key?(@user.id)
  end

  def outgoing_request
    @outgoing_requests[@user.id]
  end
end
