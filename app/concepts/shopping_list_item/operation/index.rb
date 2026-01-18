# frozen_string_literal: true

class ShoppingListItem::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    shopping_list = ShoppingList.find(params[:shopping_list_id])
    authorize! shopping_list, :show?

    items = shopping_list.shopping_list_items.includes(:added_by, :edited_by).order(created_at: :desc)

    self.model = OpenStruct.new(
      items: items,
      shopping_list: shopping_list
    )
  end
end
