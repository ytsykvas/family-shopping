# frozen_string_literal: true

class Recipe::Operation::AddToShoppingList < Base::Operation::Base
  include Rails.application.routes.url_helpers

  def perform!(params:, current_user:)
    recipe = Recipe.find(params[:id])
    authorize! recipe, :add_to_shopping_list?

    ingredient_ids = params[:ingredient_ids] || []
    ingredient_ids = ingredient_ids.reject(&:blank?)

    if ingredient_ids.empty?
      self.redirect_path = recipe_path(recipe)
      add_error(:base, I18n.t("recipes.add_to_list.empty", default: "No ingredients selected."))
      invalid!
      return
    end

    shopping_list = current_user.owned_shopping_lists.find_or_create_by(name: "Home")

    ingredients = recipe.ingredients.where(id: ingredient_ids)

    ingredients.each do |ingredient|
      shopping_list.shopping_list_items.create!(
        name: ingredient.content,
        added_by: current_user
      )
    end

    self.redirect_path = shopping_list_path(shopping_list)
    notice I18n.t("recipes.add_to_list.success", default: "Ingredients added to Home list.")
  end
end
