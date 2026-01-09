# frozen_string_literal: true

class ShoppingList::Operation::Update < Base::Operation::Base
  def perform!(params:, current_user:)
    shopping_list = ShoppingList.find(params[:id])

    authorize! shopping_list, :update?

    shopping_list.assign_attributes(shopping_list_params(params))

    if shopping_list.save
      self.model = shopping_list
      self.redirect_path = "/shopping_lists"
      notice I18n.t("shopping_lists.update.success")
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
