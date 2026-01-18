# frozen_string_literal: true

class ShoppingListItem::Component::DoneList < Base::Component::Base
  def initialize(shopping_list:, done_items:, can_manage: false)
    @shopping_list = shopping_list
    @done_items = done_items
    @can_manage = can_manage
  end

  def render?
    @done_items.any?
  end
end
