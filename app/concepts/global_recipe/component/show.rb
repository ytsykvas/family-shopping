# frozen_string_literal: true

class GlobalRecipe::Component::Show < Base::Component::Base
  def initialize(global_recipe:)
    @recipe = global_recipe
  end
end
