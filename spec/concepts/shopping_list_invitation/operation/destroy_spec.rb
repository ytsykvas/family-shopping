# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingListInvitation::Operation::Destroy do
  subject(:result) { described_class.call(params: params, current_user: current_user) }

  let(:owner) { create(:user) }
  let(:invitee) { create(:user) }
  let(:stranger) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: owner) }
  let!(:invitation) { create(:shopping_list_invitation, shopping_list: shopping_list, inviter: owner, invitee: invitee, status: :pending) }
  let(:params) { { id: invitation.id } }

  describe "#perform!" do
    context "when inviter cancels" do
      let(:current_user) { owner }

      it "deletes invitation" do
        expect { result }.to change(ShoppingListInvitation, :count).by(-1)
        expect(result).to be_success
      end
    end

    context "when invitee rejects" do
      let(:current_user) { invitee }

      it "deletes invitation" do
        expect { result }.to change(ShoppingListInvitation, :count).by(-1)
        expect(result).to be_success
      end
    end

    context "when stranger tries to destroy" do
      let(:current_user) { stranger }

      it "fails" do
        expect { result }.not_to change(ShoppingListInvitation, :count)
        expect(result).to be_failure
        expect(result.errors[:base]).to include(I18n.t("shopping_list_invitations.destroy.not_authorized"))
      end
    end
  end
end
