# frozen_string_literal: true

class Recipe::Component::IngredientFields < Base::Component::Base
  def initialize(f:)
    @f = f
  end
end
