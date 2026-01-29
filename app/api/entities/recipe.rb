module Entities
  class Recipe < Grape::Entity
    expose :id
    expose :name
    expose :description
    expose :ingredients, using: Entities::Ingredient
  end
end
