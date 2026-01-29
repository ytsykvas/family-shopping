# frozen_string_literal: true

class Recipe::Component::Card < Base::Component::Base
  def initialize(recipe:, path: nil)
    @recipe = recipe
    @path = path
  end

  private

  def show_path
    @path || helpers.recipe_path(@recipe)
  end
end
