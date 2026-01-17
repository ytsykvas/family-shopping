require "rails_helper"

RSpec.describe "ShoppingListInvitations", type: :request do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:headers) { authenticated_header(user) }
  let(:shopping_list) { create(:shopping_list, owner: user) }

  before do
    create(:friendship, requester: user, accepter: friend, status: :accepted)
  end

  describe "POST /api/v1/shopping_list_invitations" do
    it "creates an invitation" do
      expect {
        post "/api/v1/shopping_list_invitations",
             params: { shopping_list_id: shopping_list.id, invitee_id: friend.id }.to_json,
             headers: headers
      }.to change(ShoppingListInvitation, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["inviter"]["id"]).to eq(user.id)
      expect(json["invitee"]["id"]).to eq(friend.id)
    end
  end

  describe "PUT /api/v1/shopping_list_invitations/:id" do
    let(:invitation) { create(:shopping_list_invitation, shopping_list: shopping_list, inviter: user, invitee: friend, status: :pending) }
    let(:friend_headers) { authenticated_header(friend) }

    it "accepts the invitation" do
      put "/api/v1/shopping_list_invitations/#{invitation.id}", headers: friend_headers

      expect(response).to have_http_status(:ok)
      # Invitation is destroyed and membership created, so we can't check invitation status
      expect(shopping_list.reload.has_member?(friend)).to be true
    end
  end

  describe "DELETE /api/v1/shopping_list_invitations/:id" do
    let!(:invitation) { create(:shopping_list_invitation, shopping_list: shopping_list, inviter: user, invitee: friend, status: :pending) }

    it "cancels the invitation" do
      expect {
        delete "/api/v1/shopping_list_invitations/#{invitation.id}", headers: headers
      }.to change(ShoppingListInvitation, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
