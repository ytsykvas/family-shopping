# frozen_string_literal: true

class ShoppingList::Component::Index < Base::Component::Base
  def initialize(shopping_lists:, new_shopping_list:, current_user: nil)
    @shopping_lists = shopping_lists
    @new_shopping_list = new_shopping_list
    @current_user = current_user
  end
end
