# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingListInvitation, type: :model do
  describe "validations" do
    subject { create(:shopping_list_invitation) }

    it { is_expected.to belong_to(:shopping_list) }
    it { is_expected.to belong_to(:inviter).class_name("User") }
    it { is_expected.to belong_to(:invitee).class_name("User") }
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, accepted: 1, rejected: 2) }

    describe "uniqueness" do
      let(:shopping_list) { create(:shopping_list) }
      let!(:existing_invitation) { create(:shopping_list_invitation, shopping_list: shopping_list) }

      it "validates uniqueness of invitee scoped to shopping_list" do
        duplicate_invitation = build(:shopping_list_invitation, shopping_list: shopping_list, invitee: existing_invitation.invitee)
        expect(duplicate_invitation).not_to be_valid
        expect(duplicate_invitation.errors[:invitee_id]).to include("has already been invited to this list")
      end
    end
  end

  describe "scopes" do
    describe ".pending" do
      let!(:pending_invitation) { create(:shopping_list_invitation, status: :pending) }
      let!(:accepted_invitation) { create(:shopping_list_invitation, status: :accepted) }

      it "returns only pending invitations" do
        expect(described_class.pending).to include(pending_invitation)
        expect(described_class.pending).not_to include(accepted_invitation)
      end
    end
  end
end
