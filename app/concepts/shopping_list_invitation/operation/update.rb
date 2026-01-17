# frozen_string_literal: true

class ShoppingListInvitation::Operation::Update < Base::Operation::Base
  def perform!(params:, current_user:)
    invitation = ShoppingListInvitation.find(params[:id])

    # Only invitee can accept
    unless invitation.invitee_id == current_user.id
      add_error(:base, I18n.t("shopping_list_invitations.update.not_invitee"))
      invalid!
      self.redirect_path = "/shopping_lists"
      return
    end

    # Must be pending
    unless invitation.pending?
      add_error(:base, I18n.t("shopping_list_invitations.update.not_pending"))
      invalid!
      self.redirect_path = "/shopping_lists"
      return
    end

    authorize! invitation, :update?

    # Create membership
    ShoppingListUser.create!(
      shopping_list: invitation.shopping_list,
      user: invitation.invitee
    )

    # Delete the invitation
    invitation.destroy!

    self.model = invitation
    self.redirect_path = "/shopping_lists"
    notice I18n.t("shopping_list_invitations.update.success")
  end
end
