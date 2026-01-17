# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingListInvitation::Operation::Create do
  subject(:result) { described_class.call(params: params, current_user: current_user) }

  let(:owner) { create(:user) }
  let(:friend) { create(:user) }
  let(:stranger) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: owner) }
  let!(:friendship) { create(:friendship, requester: owner, accepter: friend, status: :accepted) }

  let(:params) do
    {
      shopping_list_invitation: {
        shopping_list_id: shopping_list.id,
        invitee_id: friend.id
      }
    }
  end

  describe "#perform!" do
    context "when valid" do
      let(:current_user) { owner }

      it "creates an invitation" do
        expect { result }.to change(ShoppingListInvitation, :count).by(1)
        expect(result).to be_success
        expect(result.model.status).to eq("pending")
        expect(result.model.inviter).to eq(owner)
        expect(result.model.invitee).to eq(friend)
      end
    end

    context "when user is not owner" do
      let(:current_user) { stranger }

      it "fails" do
        expect { result }.not_to change(ShoppingListInvitation, :count)
        expect(result).to be_failure
        expect(result.errors[:base]).to include(I18n.t("shopping_list_invitations.create.not_owner"))
      end
    end

    context "when invitee is not a friend" do
      let(:current_user) { owner }
      let(:params) do
        {
          shopping_list_invitation: {
            shopping_list_id: shopping_list.id,
            invitee_id: stranger.id
          }
        }
      end

      it "fails" do
        expect { result }.not_to change(ShoppingListInvitation, :count)
        expect(result).to be_failure
        expect(result.errors[:base]).to include(I18n.t("shopping_list_invitations.create.not_friend"))
      end
    end

    context "when invitee is already a member" do
      let(:current_user) { owner }
      before { create(:shopping_list_user, shopping_list: shopping_list, user: friend) }

      it "fails" do
        expect { result }.not_to change(ShoppingListInvitation, :count)
        expect(result).to be_failure
        expect(result.errors[:base]).to include(I18n.t("shopping_list_invitations.create.already_member"))
      end
    end

    context "when invitation already exists" do
      let(:current_user) { owner }
      before { create(:shopping_list_invitation, shopping_list: shopping_list, inviter: owner, invitee: friend, status: :pending) }

      it "fails" do
        expect { result }.not_to change(ShoppingListInvitation, :count)
        expect(result).to be_failure
        expect(result.errors[:base]).to include(I18n.t("shopping_list_invitations.create.already_invited"))
      end
    end
  end
end
