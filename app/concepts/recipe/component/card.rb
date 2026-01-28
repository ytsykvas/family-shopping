# frozen_string_literal: true

class Recipe::Component::Card < Base::Component::Base
  def initialize(recipe:)
    @recipe = recipe
  end
end
