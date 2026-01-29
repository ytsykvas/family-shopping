# frozen_string_literal: true

class Recipe::Component::Edit < Base::Component::Base
  def initialize(recipe:)
    @recipe = recipe
  end
end
