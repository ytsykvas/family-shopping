module Entities
  class FriendshipRequest < Grape::Entity
    expose :id
    expose :status
    expose :requester, using: Entities::User
    expose :accepter, using: Entities::User
    expose :created_at
  end
end
