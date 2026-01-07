# frozen_string_literal: true

class ShoppingList::Operation::Create < Base::Operation::Base
  def perform!(params:, current_user:)
    shopping_list_params_hash = shopping_list_params(params)

    shopping_list = ShoppingList.new(shopping_list_params_hash)
    shopping_list.owner = current_user

    authorize! shopping_list, :create?

    if shopping_list.save
      self.model = shopping_list
      self.redirect_path = "/shopping_lists"
      notice I18n.t("shopping_lists.create.success", default: "Shopping list created successfully")
    else
      self.redirect_path = "/shopping_lists"
      add_errors(shopping_list.errors)
      invalid!
    end
  end

  private

  def shopping_list_params(params)
    if params.is_a?(ActionController::Parameters)
      params.require(:shopping_list).permit(:name)
    else
      params.fetch(:shopping_list, {}).slice(:name).with_indifferent_access
    end
  end
end
