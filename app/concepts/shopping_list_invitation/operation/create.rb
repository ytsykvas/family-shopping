# frozen_string_literal: true

class ShoppingListInvitation::Operation::Create < Base::Operation::Base
  def perform!(params:, current_user:)
    invitation_params = extract_params(params)
    shopping_list = ShoppingList.find(invitation_params[:shopping_list_id])
    invitee = User.find(invitation_params[:invitee_id])

    # Check if user is owner
    unless shopping_list.owned_by?(current_user)
      add_error(:base, I18n.t("shopping_list_invitations.create.not_owner"))
      invalid!
      self.redirect_path = "/shopping_lists/#{shopping_list.id}"
      return
    end

    # Check if invitee is a friend
    unless current_user.friends.exists?(id: invitee.id)
      add_error(:base, I18n.t("shopping_list_invitations.create.not_friend"))
      invalid!
      self.redirect_path = "/shopping_lists/#{shopping_list.id}"
      return
    end

    # Check if invitee is already a member
    if shopping_list.has_member?(invitee) || shopping_list.owned_by?(invitee)
      add_error(:base, I18n.t("shopping_list_invitations.create.already_member"))
      invalid!
      self.redirect_path = "/shopping_lists/#{shopping_list.id}"
      return
    end

    # Check for existing pending invitation
    if ShoppingListInvitation.pending.exists?(shopping_list: shopping_list, invitee: invitee)
      add_error(:base, I18n.t("shopping_list_invitations.create.already_invited"))
      invalid!
      self.redirect_path = "/shopping_lists/#{shopping_list.id}"
      return
    end

    invitation = ShoppingListInvitation.new(
      shopping_list: shopping_list,
      inviter: current_user,
      invitee: invitee,
      status: :pending
    )

    authorize! invitation, :create?

    invitation.save!

    self.model = invitation
    self.redirect_path = "/shopping_lists/#{shopping_list.id}"
    notice I18n.t("shopping_list_invitations.create.success")
  end

  private

  def extract_params(params)
    if params.is_a?(ActionController::Parameters)
      params.require(:shopping_list_invitation).permit(:shopping_list_id, :invitee_id)
    else
      params.fetch(:shopping_list_invitation, {}).slice(:shopping_list_id, :invitee_id).with_indifferent_access
    end
  end
end
