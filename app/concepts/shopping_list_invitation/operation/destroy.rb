# frozen_string_literal: true

class ShoppingListInvitation::Operation::Destroy < Base::Operation::Base
  def perform!(params:, current_user:)
    invitation = ShoppingListInvitation.find(params[:id])

    # Must be inviter or invitee
    unless invitation.inviter_id == current_user.id || invitation.invitee_id == current_user.id
      add_error(:base, I18n.t("shopping_list_invitations.destroy.not_authorized"))
      invalid!
      self.redirect_path = "/shopping_lists"
      return
    end

    # Must be pending
    unless invitation.pending?
      add_error(:base, I18n.t("shopping_list_invitations.destroy.not_pending"))
      invalid!
      self.redirect_path = "/shopping_lists"
      return
    end

    authorize! invitation, :destroy?

    invitation.destroy!

    self.model = invitation
    self.redirect_path = "/shopping_lists"
    notice I18n.t("shopping_list_invitations.destroy.success")
  end
end
