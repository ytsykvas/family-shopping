# frozen_string_literal: true

class ShoppingList::Component::Edit < Base::Component::Base
  def initialize(shopping_list:)
    @shopping_list = shopping_list
  end
end
