require 'rails_helper'

RSpec.describe "ShoppingListInvitations", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: user) }

  before do
    sign_in user
  end

  describe "POST /shopping_list_invitations" do
    let(:valid_params) do
      { shopping_list_invitation: { invitee_id: other_user.id, shopping_list_id: shopping_list.id } }
    end

    before do
       # Users must be friends to invite
       create(:friendship, requester: user, accepter: other_user, status: :accepted)
       create(:friendship, requester: other_user, accepter: user, status: :accepted)
    end

    context "with valid parameters" do
      it "creates a new invitation" do
        expect {
          post shopping_list_invitations_path, params: valid_params
        }.to change(ShoppingListInvitation, :count).by(1)
        expect(response).to redirect_to(shopping_list_path(shopping_list))
      end
    end

    context "with invalid parameters" do
      it "does not create a new invitation if user already added" do
        create(:shopping_list_invitation, shopping_list: shopping_list, invitee: other_user)
        expect {
          post shopping_list_invitations_path, params: valid_params
        }.not_to change(ShoppingListInvitation, :count)

        expect(response).to redirect_to(shopping_list_path(shopping_list))
        expect(flash[:alert]).to eq(I18n.t("shopping_list_invitations.create.already_invited"))
      end
    end
  end

  describe "PUT /shopping_list_invitations/:id" do
    let(:invitation) { create(:shopping_list_invitation, shopping_list: shopping_list, invitee: user) }

    before do
       # invitation is for current_user (as invitee)
       # However, in POST create we used current_user as inviter.
       # Now let's test accept.
       sign_out user
       sign_in invitation.invitee
    end

    it "accepts the invitation" do
      put shopping_list_invitation_path(invitation)

      # Invitation is destroyed upon acceptance
      expect { invitation.reload }.to raise_error(ActiveRecord::RecordNotFound)

      # Membership is created
      expect(ShoppingListUser.exists?(shopping_list: shopping_list, user: invitation.invitee)).to be true

      expect(response).to redirect_to(shopping_lists_path) # Redirects to /shopping_lists as per operation
    end
  end

  describe "DELETE /shopping_list_invitations/:id" do
      let!(:invitation) { create(:shopping_list_invitation, shopping_list: shopping_list, inviter: user, invitee: other_user) }

      it "destroys the invitation" do
        expect {
          delete shopping_list_invitation_path(invitation)
        }.to change(ShoppingListInvitation, :count).by(-1)
        expect(response).to redirect_to(shopping_lists_path)
      end
  end
end
