# frozen_string_literal: true

class Recipe::Operation::Destroy < Base::Operation::Base
  include Rails.application.routes.url_helpers

  def perform!(params:, current_user:)
    recipe = Recipe.find(params[:id])
    authorize! recipe, :destroy?

    if recipe.destroy
      self.redirect_path = recipes_path
      notice I18n.t("recipes.destroy.success", default: "Recipe was successfully destroyed.")
    else
      self.redirect_path = recipes_path
      add_errors(recipe.errors)
      notice I18n.t("recipes.destroy.failure", default: "Failed to delete recipe."), level: :alert
    end
  end
end
