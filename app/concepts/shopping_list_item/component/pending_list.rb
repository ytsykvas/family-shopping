# frozen_string_literal: true

class ShoppingListItem::Component::PendingList < Base::Component::Base
  def initialize(shopping_list:, pending_items:, can_manage: false)
    @shopping_list = shopping_list
    @pending_items = pending_items
    @can_manage = can_manage
  end
end
