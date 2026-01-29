# frozen_string_literal: true

class ShoppingList::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! ShoppingList, :index?

    shopping_lists = policy_scope(ShoppingList).order(created_at: :desc).page(params[:page]).per(21)
    pending_invitations = current_user&.received_shopping_list_invitations&.pending&.includes(:shopping_list, :inviter) || []

    self.model = OpenStruct.new(
      shopping_lists: shopping_lists,
      new_shopping_list: ShoppingList.new,
      current_user: current_user,
      pending_invitations: pending_invitations
    )
  end
end
