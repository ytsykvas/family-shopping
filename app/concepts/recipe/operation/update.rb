# frozen_string_literal: true

class Recipe::Operation::Update < Base::Operation::Base
  include Rails.application.routes.url_helpers

  def perform!(params:, current_user:)
    @recipe = Recipe.find(params[:id])
    authorize! @recipe, :update?

    if @recipe.update(recipe_params(params))
      self.model = @recipe
      self.redirect_path = recipe_path(@recipe)
      notice I18n.t("recipes.update.success", default: "Recipe was successfully updated.")
    else
      self.model = @recipe
      add_errors(@recipe.errors)
      invalid!
    end
  end

  private

  def recipe_params(params)
    params.require(:recipe).permit(:name, :description, ingredients_attributes: [ :id, :content, :_destroy ])
  end
end
