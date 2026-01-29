# frozen_string_literal: true

class GlobalRecipe::Operation::Show < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! :global_recipe, :show?

    self.model = Recipe.find(params[:id])
  end
end
