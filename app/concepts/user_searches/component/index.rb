# frozen_string_literal: true

class UserSearches::Component::Index < Base::Component::Base
  def initialize(query: nil, users: [])
    @query = query
    @users = users
  end

  def has_query?
    @query.present?
  end

  def has_results?
    @users.any?
  end
end
