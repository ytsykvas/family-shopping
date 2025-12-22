# frozen_string_literal: true

class UserSearches::Component::Results < Base::Component::Base
  def initialize(query:, users:, friends_ids: [], incoming_requests: {}, outgoing_requests: {})
    @query = query
    @users = users
    @friends_ids = friends_ids
    @incoming_requests = incoming_requests
    @outgoing_requests = outgoing_requests
  end

  def has_query?
    @query.present?
  end

  def has_results?
    @users.any?
  end
end
