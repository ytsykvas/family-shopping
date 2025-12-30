# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingList, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:owner).class_name("User") }
    it { is_expected.to have_many(:shopping_list_items).dependent(:destroy) }
    it { is_expected.to have_many(:shopping_list_users).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:shopping_list_users).source(:user) }

    describe "owner association" do
      let(:owner) { create(:user) }
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      it "belongs to an owner" do
        expect(shopping_list.owner).to eq(owner)
      end

      it "requires an owner" do
        shopping_list.owner = nil
        expect(shopping_list).not_to be_valid
      end
    end

    describe "shopping_list_items association" do
      let(:shopping_list) { create(:shopping_list) }
      let!(:item1) { create(:shopping_list_item, shopping_list: shopping_list) }
      let!(:item2) { create(:shopping_list_item, shopping_list: shopping_list) }

      it "has many shopping list items" do
        expect(shopping_list.shopping_list_items).to include(item1, item2)
      end

      it "destroys associated items when destroyed" do
        shopping_list.destroy
        expect(ShoppingListItem.find_by(id: item1.id)).to be_nil
        expect(ShoppingListItem.find_by(id: item2.id)).to be_nil
      end
    end

    describe "shopping_list_users association" do
      let(:shopping_list) { create(:shopping_list) }
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }
      let!(:list_user1) { create(:shopping_list_user, shopping_list: shopping_list, user: user1) }
      let!(:list_user2) { create(:shopping_list_user, shopping_list: shopping_list, user: user2) }

      it "has many shopping list users" do
        expect(shopping_list.shopping_list_users).to include(list_user1, list_user2)
      end

      it "has many members through shopping_list_users" do
        expect(shopping_list.members).to include(user1, user2)
      end

      it "destroys associated shopping_list_users when destroyed" do
        shopping_list.destroy
        expect(ShoppingListUser.find_by(id: list_user1.id)).to be_nil
        expect(ShoppingListUser.find_by(id: list_user2.id)).to be_nil
      end
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    context "when name is blank" do
      let(:shopping_list) { build(:shopping_list, name: "") }

      it "is not valid" do
        expect(shopping_list).not_to be_valid
        expect(shopping_list.errors[:name]).to be_present
      end
    end

    context "when name is nil" do
      let(:shopping_list) { build(:shopping_list, name: nil) }

      it "is not valid" do
        expect(shopping_list).not_to be_valid
        expect(shopping_list.errors[:name]).to be_present
      end
    end

    context "when name is present" do
      let(:shopping_list) { build(:shopping_list, name: "Groceries") }

      it "is valid" do
        expect(shopping_list).to be_valid
      end
    end
  end

  describe "factory" do
    it "creates a valid shopping list" do
      shopping_list = build(:shopping_list)
      expect(shopping_list).to be_valid
    end

    it "creates a shopping list with all required attributes" do
      shopping_list = create(:shopping_list)
      expect(shopping_list.name).to be_present
      expect(shopping_list.owner).to be_present
    end

    context "with with_members trait" do
      it "creates shopping list with members" do
        shopping_list = create(:shopping_list, :with_members, members_count: 3)
        expect(shopping_list.shopping_list_users.count).to eq(3)
        expect(shopping_list.members.count).to eq(3)
      end

      it "creates shopping list with default members count" do
        shopping_list = create(:shopping_list, :with_members)
        expect(shopping_list.shopping_list_users.count).to eq(2)
      end
    end
  end

  describe "cascade deletion" do
    let(:shopping_list) { create(:shopping_list) }
    let!(:item1) { create(:shopping_list_item, shopping_list: shopping_list) }
    let!(:item2) { create(:shopping_list_item, shopping_list: shopping_list) }
    let!(:user1) { create(:user) }
    let!(:list_user) { create(:shopping_list_user, shopping_list: shopping_list, user: user1) }

    it "destroys all associated records when shopping list is destroyed" do
      shopping_list_id = shopping_list.id
      shopping_list.destroy

      expect(ShoppingListItem.where(shopping_list_id: shopping_list_id)).to be_empty
      expect(ShoppingListUser.where(shopping_list_id: shopping_list_id)).to be_empty
    end

    it "does not destroy associated users when shopping list is destroyed" do
      user_id = user1.id
      shopping_list.destroy
      expect(User.find_by(id: user_id)).to be_present
    end
  end

  describe "#owned_by?" do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let(:shopping_list) { create(:shopping_list, owner: owner) }

    context "when user is the owner" do
      it "returns true" do
        expect(shopping_list.owned_by?(owner)).to be true
      end
    end

    context "when user is not the owner" do
      it "returns false" do
        expect(shopping_list.owned_by?(other_user)).to be false
      end
    end

    context "when user is nil" do
      it "returns false" do
        expect(shopping_list.owned_by?(nil)).to be false
      end
    end
  end

  describe "#has_member?" do
    let(:owner) { create(:user) }
    let(:member) { create(:user) }
    let(:other_user) { create(:user) }
    let(:shopping_list) { create(:shopping_list, owner: owner) }

    before do
      create(:shopping_list_user, shopping_list: shopping_list, user: member)
    end

    context "when user is a member" do
      it "returns true" do
        expect(shopping_list.has_member?(member)).to be true
      end
    end

    context "when user is not a member" do
      it "returns false" do
        expect(shopping_list.has_member?(other_user)).to be false
      end
    end

    context "when user is the owner but not a member" do
      it "returns false" do
        expect(shopping_list.has_member?(owner)).to be false
      end
    end

    context "when user is nil" do
      it "returns false" do
        expect(shopping_list.has_member?(nil)).to be false
      end
    end
  end

  describe "#accessible_by?" do
    let(:owner) { create(:user) }
    let(:member) { create(:user) }
    let(:other_user) { create(:user) }
    let(:shopping_list) { create(:shopping_list, owner: owner) }

    before do
      create(:shopping_list_user, shopping_list: shopping_list, user: member)
    end

    context "when user is the owner" do
      it "returns true" do
        expect(shopping_list.accessible_by?(owner)).to be true
      end
    end

    context "when user is a member" do
      it "returns true" do
        expect(shopping_list.accessible_by?(member)).to be true
      end
    end

    context "when user is neither owner nor member" do
      it "returns false" do
        expect(shopping_list.accessible_by?(other_user)).to be false
      end
    end

    context "when user is nil" do
      it "returns false" do
        expect(shopping_list.accessible_by?(nil)).to be false
      end
    end
  end
end
