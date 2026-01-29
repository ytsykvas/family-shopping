# frozen_string_literal: true

class GlobalRecipe::Component::Index < Base::Component::Base
  def initialize(global_recipes:, params: {})
    @recipes = global_recipes
    @params = params
  end
end
