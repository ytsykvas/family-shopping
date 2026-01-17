# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingListInvitationPolicy, type: :policy do
  subject { described_class }

  let(:shopping_list_owner) { create(:user) }
  let(:invitee) { create(:user) }
  let(:outsider) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: shopping_list_owner) }
  let(:invitation) { create(:shopping_list_invitation, shopping_list: shopping_list, inviter: shopping_list_owner, invitee: invitee) }

  describe "#create?" do
    it "grants access if user is owner of the shopping list" do
      expect(subject.new(shopping_list_owner, invitation).create?).to be true
    end

    it "denies access if user is not owner" do
      expect(subject.new(invitee, invitation).create?).to be false
    end
  end

  describe "#update?" do
    it "grants access if user is the invitee" do
      expect(subject.new(invitee, invitation).update?).to be true
    end

    it "denies access if user is the inviter" do
      expect(subject.new(shopping_list_owner, invitation).update?).to be false
    end

    it "denies access if user is an outsider" do
      expect(subject.new(outsider, invitation).update?).to be false
    end
  end

  describe "#destroy?" do
    it "grants access if user is the inviter" do
      expect(subject.new(shopping_list_owner, invitation).destroy?).to be true
    end

    it "grants access if user is the invitee" do
      expect(subject.new(invitee, invitation).destroy?).to be true
    end

    it "denies access if user is an outsider" do
      expect(subject.new(outsider, invitation).destroy?).to be false
    end
  end

  describe "Scope" do
    let!(:my_sent_invitation) { create(:shopping_list_invitation, inviter: shopping_list_owner) }
    let!(:my_received_invitation) { create(:shopping_list_invitation, invitee: shopping_list_owner) }
    let!(:other_invitation) { create(:shopping_list_invitation) }

    it "includes invitations where user is inviter or invitee" do
      scope = ShoppingListInvitationPolicy::Scope.new(shopping_list_owner, ShoppingListInvitation).resolve
      expect(scope).to include(my_sent_invitation)
      expect(scope).to include(my_received_invitation)
      expect(scope).not_to include(other_invitation)
    end
  end
end
