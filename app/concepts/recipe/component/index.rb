# frozen_string_literal: true

class Recipe::Component::Index < Base::Component::Base
  def initialize(recipes:, delete_modal: nil)
    @recipes = recipes
  end
end
