module Entities
  class ShoppingListInvitation < Grape::Entity
    expose :id
    expose :status
    expose :inviter, using: Entities::User
    expose :invitee, using: Entities::User
    expose :shopping_list, using: Entities::ShoppingList
    expose :created_at
  end
end
