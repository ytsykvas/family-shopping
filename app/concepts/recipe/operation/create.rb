# frozen_string_literal: true

class Recipe::Operation::Create < Base::Operation::Base
  include Rails.application.routes.url_helpers

  def perform!(params:, current_user:)
    @recipe = current_user.recipes.new(recipe_params(params))
    authorize! @recipe, :create?

    if @recipe.save
      self.model = @recipe
      self.redirect_path = recipe_path(@recipe)
      notice I18n.t("recipes.create.success", default: "Recipe was successfully created.")
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
