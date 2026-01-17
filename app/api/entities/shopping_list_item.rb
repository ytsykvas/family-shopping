module Entities
  class ShoppingListItem < Grape::Entity
    expose :id
    expose :name
    expose :quantity
    expose :bought
    expose :created_at
    expose :updated_at
  end
end
