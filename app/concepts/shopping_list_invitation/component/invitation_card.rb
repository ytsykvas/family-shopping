# frozen_string_literal: true

class ShoppingListInvitation::Component::InvitationCard < Base::Component::Base
  def initialize(invitation:, current_user:)
    @invitation = invitation
    @current_user = current_user
  end

  def incoming?
    @invitation.invitee_id == @current_user.id
  end

  def inviter_name
    @invitation.inviter.name || @invitation.inviter.nickname
  end

  def list_name
    @invitation.shopping_list.name
  end
end
