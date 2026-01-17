# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingListInvitation::Operation::Update do
  subject(:result) { described_class.call(params: params, current_user: current_user) }

  let(:owner) { create(:user) }
  let(:invitee) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: owner) }
  let!(:invitation) { create(:shopping_list_invitation, shopping_list: shopping_list, inviter: owner, invitee: invitee, status: :pending) }
  let(:params) { { id: invitation.id } }

  describe "#perform!" do
    context "when invitee accepts" do
      let(:current_user) { invitee }

      it "creates membership and deletes invitation" do
        expect { result }.to change(ShoppingListUser, :count).by(1)
          .and change(ShoppingListInvitation, :count).by(-1)

        expect(result).to be_success
        expect(shopping_list.members).to include(invitee)
      end
    end

    context "when inviter tries to accept" do
      let(:current_user) { owner }

      it "fails" do
        expect { result }.not_to change(ShoppingListUser, :count)
        expect(result).to be_failure
        expect(result.errors[:base]).to include(I18n.t("shopping_list_invitations.update.not_invitee"))
      end
    end

    context "when invitation is not pending" do
      let(:current_user) { invitee }
      before { invitation.update(status: :rejected) } # Should generally not happen as we delete them, but logic handles it

      it "fails" do
        expect(result).to be_failure
        # Note: Depending on implementation, find might fail if logic is strictly pending scope only,
        # but operation currently does find(id) then pending?.
        expect(result.errors[:base]).to include(I18n.t("shopping_list_invitations.update.not_pending"))
      end
    end
  end
end
