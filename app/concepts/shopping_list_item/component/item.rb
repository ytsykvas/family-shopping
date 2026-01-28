# frozen_string_literal: true

class ShoppingListItem::Component::Item < Base::Component::Base
  def initialize(shopping_list:, item:, can_manage: false)
    @shopping_list = shopping_list
    @item = item
    @can_manage = can_manage
  end

  def item_class
    classes = [ "shopping-item", "d-flex", "align-items-center", "justify-content-between", "mb-2" ]
    classes << "shopping-item-done" if @item.done_status?
    classes.join(" ")
  end
end
