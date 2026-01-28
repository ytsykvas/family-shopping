# frozen_string_literal: true

class Recipe::Operation::New < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! Recipe, :new?

    recipe = current_user.recipes.new
    recipe.ingredients.build # Initial ingredient field

    self.model = recipe
  end
end
