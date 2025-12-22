# frozen_string_literal: true

class UserSearches::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    skip_authorize

    query = params[:query]&.strip

    if query.blank?
      policy_scope(User).none
      self.model = { query: nil, users: [], friends_ids: [], incoming_requests: {}, outgoing_requests: {} }
      return
    end

    users = policy_scope(User).where(
      "lower(nickname) LIKE ? OR lower(email) LIKE ?",
      "%#{query.downcase}%",
      "%#{query.downcase}%"
    ).where.not(id: current_user.id).limit(10)

    user_ids = users.pluck(:id)

    friendships = Friendship
      .where("(requester_id = :user_id OR accepter_id = :user_id)", user_id: current_user.id)
      .where("requester_id IN (:user_ids) OR accepter_id IN (:user_ids)", user_ids: user_ids)
      .to_a

    friends_ids = []
    incoming_requests = {}
    outgoing_requests = {}

    friendships.each do |friendship|
      if friendship.accepted?
        friend_id = friendship.requester_id == current_user.id ? friendship.accepter_id : friendship.requester_id
        friends_ids << friend_id
      elsif friendship.pending?
        if friendship.accepter_id == current_user.id
          incoming_requests[friendship.requester_id] = friendship
        elsif friendship.requester_id == current_user.id
          outgoing_requests[friendship.accepter_id] = friendship
        end
      end
    end

    self.model = {
      query: query,
      users: users,
      friends_ids: friends_ids,
      incoming_requests: incoming_requests,
      outgoing_requests: outgoing_requests
    }
  end
end
