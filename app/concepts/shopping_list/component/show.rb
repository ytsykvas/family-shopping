# frozen_string_literal: true

class ShoppingList::Component::Show < Base::Component::Base
  def initialize(shopping_list:, current_user: nil, friends: [])
    @shopping_list = shopping_list
    @current_user = current_user
    @friends = friends
  end
end
