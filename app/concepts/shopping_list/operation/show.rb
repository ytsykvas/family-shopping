# frozen_string_literal: true

class ShoppingList::Operation::Show < Base::Operation::Base
  def perform!(params:, current_user:)
    shopping_list = ShoppingList.includes(:owner, :members, :shopping_list_items, :invitations).find(params[:id])

    authorize! shopping_list, :show?

    self.model = OpenStruct.new(
      shopping_list: shopping_list,
      current_user: current_user,
      friends: current_user&.friends || []
    )
  end
end
