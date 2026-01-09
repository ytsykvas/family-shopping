# frozen_string_literal: true

class ShoppingList::Component::ListItem < Base::Component::Base
  def initialize(shopping_list:)
    @shopping_list = shopping_list
  end
end
