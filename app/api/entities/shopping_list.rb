module Entities
  class ShoppingList < Grape::Entity
    expose :id
    expose :name
    expose :items_count do |shopping_list|
      shopping_list.shopping_list_items.count
    end
    expose :members_count do |shopping_list|
      shopping_list.members.count
    end
    expose :owner, using: Entities::User
    expose :created_at
    expose :updated_at
  end
end
