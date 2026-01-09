# frozen_string_literal: true

class ShoppingList::Operation::Destroy < Base::Operation::Base
  def perform!(params:, current_user:)
    shopping_list = ShoppingList.find(params[:id])

    authorize! shopping_list, :destroy?

    if shopping_list.destroy
      self.redirect_path = "/shopping_lists"
      notice I18n.t("shopping_lists.destroy.success")
    else
      self.redirect_path = "/shopping_lists"
      add_errors(shopping_list.errors)
      invalid!
    end
  end
end
