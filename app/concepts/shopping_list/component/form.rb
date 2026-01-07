# frozen_string_literal: true

class ShoppingList::Component::Form < Base::Component::Base
  def initialize(shopping_list:)
    @shopping_list = shopping_list
  end
end
