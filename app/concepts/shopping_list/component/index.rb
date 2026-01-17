# frozen_string_literal: true

class ShoppingList::Component::Index < Base::Component::Base
  def initialize(shopping_lists:, new_shopping_list:, current_user: nil, pending_invitations: [])
    @shopping_lists = shopping_lists
    @new_shopping_list = new_shopping_list
    @current_user = current_user
    @pending_invitations = pending_invitations
  end
end
