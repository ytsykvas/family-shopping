# frozen_string_literal: true

class ShoppingListItem::Operation::Update < Base::Operation::Base
  def perform!(params:, current_user:)
    shopping_list = ShoppingList.find(params[:shopping_list_id])
    item = shopping_list.shopping_list_items.find(params[:id])

    authorize! item, :update?

    item.assign_attributes(item_params(params))
    item.edited_by = current_user

    if item.save
      self.model = item
      self.redirect_path = shopping_list_path(shopping_list)
      notice I18n.t("shopping_list_items.update.success")
    else
      self.redirect_path = shopping_list_path(shopping_list)
      add_errors(item.errors)
      invalid!
    end
  end

  private

  def item_params(params)
    if params.is_a?(ActionController::Parameters)
      params.require(:shopping_list_item).permit(:name, :status)
    else
      params.fetch(:shopping_list_item, {}).slice(:name, :status).with_indifferent_access
    end
  end

  def shopping_list_path(shopping_list)
    "/shopping_lists/#{shopping_list.id}"
  end
end
