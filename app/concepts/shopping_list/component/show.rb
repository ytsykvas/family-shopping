# frozen_string_literal: true

class ShoppingList::Component::Show < Base::Component::Base
  def initialize(shopping_list:, current_user: nil, friends: [])
    @shopping_list = shopping_list
    @current_user = current_user
    @friends = friends
  end

  def pending_items
    @shopping_list.shopping_list_items.pending_status.order(created_at: :desc)
  end

  def done_items
    @shopping_list.shopping_list_items.done_status.order(updated_at: :desc)
  end

  def can_manage_items?
    helpers.policy(ShoppingListItem.new(shopping_list: @shopping_list)).create?
  end
end
