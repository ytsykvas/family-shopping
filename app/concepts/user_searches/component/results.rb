# frozen_string_literal: true

class UserSearches::Component::Results < Base::Component::Base
  def initialize(query:, users:)
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
