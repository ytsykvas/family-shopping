# frozen_string_literal: true

class ShoppingListItem::Component::NewForm < Base::Component::Base
  def initialize(shopping_list:)
    @shopping_list = shopping_list
  end

  def can_manage?
    helpers.policy(ShoppingListItem.new(shopping_list: @shopping_list)).create?
  end

  def render?
    can_manage?
  end
end
