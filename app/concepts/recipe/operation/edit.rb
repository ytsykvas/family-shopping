# frozen_string_literal: true

class Recipe::Operation::Edit < Base::Operation::Base
  def perform!(params:, current_user:)
    @recipe = Recipe.find(params[:id])
    authorize! @recipe, :update?

    self.model = @recipe
  end
end
