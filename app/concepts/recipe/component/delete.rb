# frozen_string_literal: true

class Recipe::Component::Delete < Base::Component::Base
  def initialize(recipe:)
    @recipe = recipe
  end
end
