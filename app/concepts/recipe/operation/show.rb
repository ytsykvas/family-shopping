# frozen_string_literal: true

class Recipe::Operation::Show < Base::Operation::Base
  def perform!(params:, current_user:)
    recipe = Recipe.find(params[:id])
    authorize! recipe, :show?

    self.model = recipe
  end
end
