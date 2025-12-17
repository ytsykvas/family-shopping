# frozen_string_literal: true

class UserSearches::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    skip_authorize

    query = params[:query]&.strip

    if query.blank?
      # Still call policy_scope to mark it as called, even though we return empty results
      policy_scope(User).none
      self.model = { query: nil, users: [] }
      return
    end

    users = policy_scope(User).where(
      "lower(nickname) LIKE ? OR lower(email) LIKE ?",
      "%#{query.downcase}%",
      "%#{query.downcase}%"
    ).where.not(id: current_user.id).limit(10)

    self.model = { query: query, users: users }
  end
end
