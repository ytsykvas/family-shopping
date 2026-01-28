# frozen_string_literal: true

class ShoppingListItem::Operation::Destroy < Base::Operation::Base
  def perform!(params:, current_user:)
    shopping_list = ShoppingList.find(params[:shopping_list_id])
    item = shopping_list.shopping_list_items.find(params[:id])

    authorize! item, :destroy?

    self.model = item

    if item.destroy
      self.redirect_path = shopping_list_path(shopping_list)
      notice I18n.t("shopping_list_items.destroy.success")
    else
      self.redirect_path = shopping_list_path(shopping_list)
      add_errors(item.errors)
      invalid!
    end
  end

  private

  def shopping_list_path(shopping_list)
    "/shopping_lists/#{shopping_list.id}"
  end
end
