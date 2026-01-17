# frozen_string_literal: true

class ShoppingListInvitation::Component::InviteModal < Base::Component::Base
  def initialize(shopping_list:, friends:)
    @shopping_list = shopping_list
    @friends = friends
  end
end
