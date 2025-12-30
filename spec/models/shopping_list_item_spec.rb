# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingListItem, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:shopping_list) }
    it { is_expected.to belong_to(:added_by).class_name("User") }
    it { is_expected.to belong_to(:edited_by).class_name("User").optional }

    describe "shopping_list association" do
      let(:shopping_list) { create(:shopping_list) }
      let(:user) { create(:user) }
      let(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: user) }

      it "belongs to a shopping list" do
        expect(item.shopping_list).to eq(shopping_list)
      end

      it "requires a shopping list" do
        item.shopping_list = nil
        expect(item).not_to be_valid
      end
    end

    describe "added_by association" do
      let(:shopping_list) { create(:shopping_list) }
      let(:user) { create(:user) }
      let(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: user) }

      it "belongs to added_by user" do
        expect(item.added_by).to eq(user)
      end

      it "requires added_by user" do
        item.added_by = nil
        expect(item).not_to be_valid
      end
    end

    describe "edited_by association" do
      let(:shopping_list) { create(:shopping_list) }
      let(:added_by_user) { create(:user) }
      let(:edited_by_user) { create(:user) }

      context "when item has been edited" do
        let(:item) { create(:shopping_list_item, :with_editor, shopping_list: shopping_list, added_by: added_by_user, edited_by: edited_by_user) }

        it "belongs to edited_by user" do
          expect(item.edited_by).to eq(edited_by_user)
        end
      end

      context "when item has not been edited" do
        let(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: added_by_user) }

        it "edited_by can be nil" do
          expect(item.edited_by).to be_nil
          expect(item).to be_valid
        end
      end
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    context "when name is blank" do
      let(:item) { build(:shopping_list_item, name: "") }

      it "is not valid" do
        expect(item).not_to be_valid
        expect(item.errors[:name]).to be_present
      end
    end

    context "when name is nil" do
      let(:item) { build(:shopping_list_item, name: nil) }

      it "is not valid" do
        expect(item).not_to be_valid
        expect(item.errors[:name]).to be_present
      end
    end

    context "when name is present" do
      let(:item) { build(:shopping_list_item, name: "Milk") }

      it "is valid" do
        expect(item).to be_valid
      end
    end
  end

  describe "status enum" do
    let(:item) { create(:shopping_list_item) }

    it "has pending status by default" do
      expect(item.status).to eq("pending")
      expect(item.pending_status?).to be true
    end

    it "can be set to done" do
      item.update(status: "done")
      expect(item.status).to eq("done")
      expect(item.done_status?).to be true
    end

    it "has status suffix methods" do
      expect(item).to respond_to(:pending_status?)
      expect(item).to respond_to(:done_status?)
    end

    context "when created with done trait" do
      let(:done_item) { create(:shopping_list_item, :done) }

      it "has done status" do
        expect(done_item.status).to eq("done")
        expect(done_item.done_status?).to be true
      end
    end
  end

  describe "factory" do
    it "creates a valid shopping list item" do
      item = build(:shopping_list_item)
      expect(item).to be_valid
    end

    it "creates a shopping list item with all required attributes" do
      item = create(:shopping_list_item)
      expect(item.name).to be_present
      expect(item.shopping_list).to be_present
      expect(item.added_by).to be_present
      expect(item.status).to eq("pending")
    end

    context "with done trait" do
      it "creates item with done status" do
        item = create(:shopping_list_item, :done)
        expect(item.status).to eq("done")
        expect(item.done_status?).to be true
      end
    end

    context "with with_editor trait" do
      it "creates item with edited_by user" do
        item = create(:shopping_list_item, :with_editor)
        expect(item.edited_by).to be_present
        expect(item.edited_by).to be_a(User)
      end
    end
  end

  describe "status transitions" do
    let(:item) { create(:shopping_list_item) }

    it "can transition from pending to done" do
      expect(item.pending_status?).to be true
      item.update(status: "done")
      expect(item.done_status?).to be true
    end

    it "can transition from done to pending" do
      item.update(status: "done")
      expect(item.done_status?).to be true
      item.update(status: "pending")
      expect(item.pending_status?).to be true
    end
  end

  describe "multiple items per shopping list" do
    let(:shopping_list) { create(:shopping_list) }
    let(:user) { create(:user) }

    it "allows multiple items in same shopping list" do
      item1 = create(:shopping_list_item, shopping_list: shopping_list, added_by: user, name: "Milk")
      item2 = create(:shopping_list_item, shopping_list: shopping_list, added_by: user, name: "Bread")
      item3 = create(:shopping_list_item, shopping_list: shopping_list, added_by: user, name: "Eggs")

      expect(shopping_list.shopping_list_items).to include(item1, item2, item3)
    end

    it "allows items with same name in same shopping list" do
      item1 = create(:shopping_list_item, shopping_list: shopping_list, added_by: user, name: "Milk")
      item2 = create(:shopping_list_item, shopping_list: shopping_list, added_by: user, name: "Milk")

      expect(shopping_list.shopping_list_items).to include(item1, item2)
    end
  end

  describe "user tracking" do
    let(:shopping_list) { create(:shopping_list) }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: user1) }

    it "tracks who added the item" do
      expect(item.added_by).to eq(user1)
    end

    it "tracks who edited the item" do
      item.update(edited_by: user2)
      expect(item.edited_by).to eq(user2)
    end

    it "allows added_by and edited_by to be different users" do
      item.update(edited_by: user2)
      expect(item.added_by).to eq(user1)
      expect(item.edited_by).to eq(user2)
      expect(item.added_by).not_to eq(item.edited_by)
    end

    it "allows added_by and edited_by to be same user" do
      item.update(edited_by: user1)
      expect(item.added_by).to eq(user1)
      expect(item.edited_by).to eq(user1)
    end
  end

  describe "delegated methods" do
    let(:owner) { create(:user) }
    let(:member) { create(:user) }
    let(:other_user) { create(:user) }
    let(:shopping_list) { create(:shopping_list, owner: owner) }
    let(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }

    before do
      create(:shopping_list_user, shopping_list: shopping_list, user: member)
    end

    describe "#list_owned_by?" do
      it "delegates to shopping_list.owned_by?" do
        expect(item.list_owned_by?(owner)).to be true
        expect(item.list_owned_by?(member)).to be false
        expect(item.list_owned_by?(other_user)).to be false
      end
    end

    describe "#list_has_member?" do
      it "delegates to shopping_list.has_member?" do
        expect(item.list_has_member?(member)).to be true
        expect(item.list_has_member?(owner)).to be false
        expect(item.list_has_member?(other_user)).to be false
      end
    end

    describe "#list_accessible_by?" do
      it "delegates to shopping_list.accessible_by?" do
        expect(item.list_accessible_by?(owner)).to be true
        expect(item.list_accessible_by?(member)).to be true
        expect(item.list_accessible_by?(other_user)).to be false
      end
    end
  end
end
