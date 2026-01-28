# frozen_string_literal: true

class Recipe::Component::AddToShoppingListModal < Base::Component::Base
  def initialize(recipe:)
    @recipe = recipe
  end
end
