# frozen_string_literal: true

class ShoppingList::Component::ListItem < Base::Component::Base
  def initialize(shopping_list:)
    @shopping_list = shopping_list
  end

  def pending_items
    @shopping_list.shopping_list_items.pending_status.order(created_at: :desc).limit(5)
  end

  def pending_items_count
    @shopping_list.shopping_list_items.pending_status.count
  end
end
