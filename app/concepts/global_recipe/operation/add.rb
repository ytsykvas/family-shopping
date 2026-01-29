# frozen_string_literal: true

class GlobalRecipe::Operation::Add < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! :global_recipe, :add?

    original_recipe = Recipe.find(params[:id])

    new_recipe = original_recipe.dup
    new_recipe.user = current_user
    new_recipe.original_recipe = original_recipe
    new_recipe.copies_count = 0

    original_recipe.ingredients.each do |ingredient|
      new_ingredient = ingredient.dup
      new_ingredient.recipe = new_recipe
      new_recipe.ingredients << new_ingredient
    end

    if new_recipe.save
      self.model = new_recipe
    else
      fail!(new_recipe.errors.full_messages)
    end
  end
end
