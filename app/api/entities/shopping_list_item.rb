module Entities
  class ShoppingListItem < Grape::Entity
    expose :id
    expose :name
    expose :status
    expose :added_by, using: Entities::User
    expose :edited_by, using: Entities::User
    expose :created_at
    expose :updated_at
  end
end
