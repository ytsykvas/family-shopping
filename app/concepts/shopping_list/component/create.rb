# frozen_string_literal: true

class ShoppingList::Component::Create < Base::Component::Base
  def initialize(new_shopping_list:)
    @new_shopping_list = new_shopping_list
  end
end
