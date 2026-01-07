# frozen_string_literal: true

class ShoppingList::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! ShoppingList, :index?

    shopping_lists = policy_scope(ShoppingList).order(created_at: :desc)

    self.model = OpenStruct.new(
      shopping_lists: shopping_lists,
      new_shopping_list: ShoppingList.new,
      current_user: current_user
    )
  end
end
