# frozen_string_literal: true

class ShoppingList::Component::Members < Base::Component::Base
  def initialize(shopping_list:, current_user: nil, friends: [])
    @shopping_list = shopping_list
    @current_user = current_user
    @friends = friends
  end

  def owner?
    @shopping_list.owned_by?(@current_user)
  end

  def invitable_friends
    member_ids = @shopping_list.members.pluck(:id)
    pending_invitee_ids = @shopping_list.invitations.pending.pluck(:invitee_id)
    excluded_ids = member_ids + pending_invitee_ids + [ @shopping_list.owner_id ]
    @friends.reject { |f| excluded_ids.include?(f.id) }
  end

  def member?
    @shopping_list.has_member?(@current_user) && !owner?
  end

  def current_membership
    @shopping_list.shopping_list_users.find_by(user: @current_user)
  end
end
