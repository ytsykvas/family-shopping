class GlobalRecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    endpoint GlobalRecipe::Operation::Index, GlobalRecipe::Component::Index
  end

  def show
    endpoint GlobalRecipe::Operation::Show, GlobalRecipe::Component::Show
  end

  def add
    result = GlobalRecipe::Operation::Add.call(params: params, current_user: current_user)
    check_authorization_is_called(result)

    if result.success?
      redirect_to recipes_path, notice: I18n.t("global_recipes.added", default: "Recipe added successfully")
    else
      redirect_to global_recipes_path, alert: result.error_message || "Failed to add recipe"
    end
  end
end
