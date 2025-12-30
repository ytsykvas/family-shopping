# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingListItemPolicy, type: :policy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:member) { create(:user) }
  let(:other_user) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: owner) }

  before do
    create(:shopping_list_user, shopping_list: shopping_list, user: member)
  end

  describe "#index?" do
    let(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }

    context "when user is the owner of the list" do
      it "allows access" do
        expect(subject.new(owner, item).index?).to be true
      end
    end

    context "when user is a member of the list" do
      it "allows access" do
        expect(subject.new(member, item).index?).to be true
      end
    end

    context "when user is neither owner nor member" do
      it "denies access" do
        expect(subject.new(other_user, item).index?).to be false
      end
    end

    context "when user is nil" do
      it "denies access" do
        expect(subject.new(nil, item).index?).to be false
      end
    end
  end

  describe "#show?" do
    let(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }

    context "when user is the owner of the list" do
      it "allows access" do
        expect(subject.new(owner, item).show?).to be true
      end
    end

    context "when user is a member of the list" do
      it "allows access" do
        expect(subject.new(member, item).show?).to be true
      end
    end

    context "when user is neither owner nor member" do
      it "denies access" do
        expect(subject.new(other_user, item).show?).to be false
      end
    end

    context "when user is nil" do
      it "denies access" do
        expect(subject.new(nil, item).show?).to be false
      end
    end
  end

  describe "#create?" do
    let(:item) { build(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }

    context "when user is the owner of the list" do
      it "allows access" do
        expect(subject.new(owner, item).create?).to be true
      end
    end

    context "when user is a member of the list" do
      it "allows access" do
        expect(subject.new(member, item).create?).to be true
      end
    end

    context "when user is neither owner nor member" do
      it "denies access" do
        expect(subject.new(other_user, item).create?).to be false
      end
    end

    context "when user is nil" do
      it "denies access" do
        expect(subject.new(nil, item).create?).to be false
      end
    end
  end

  describe "#new?" do
    let(:item) { build(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }

    context "when user is the owner of the list" do
      it "allows access" do
        expect(subject.new(owner, item).new?).to be true
      end
    end

    context "when user is a member of the list" do
      it "allows access" do
        expect(subject.new(member, item).new?).to be true
      end
    end
  end

  describe "#update?" do
    let(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }

    context "when user is the owner of the list" do
      it "allows access" do
        expect(subject.new(owner, item).update?).to be true
      end
    end

    context "when user is a member of the list" do
      it "allows access" do
        expect(subject.new(member, item).update?).to be true
      end
    end

    context "when user is neither owner nor member" do
      it "denies access" do
        expect(subject.new(other_user, item).update?).to be false
      end
    end

    context "when user is nil" do
      it "denies access" do
        expect(subject.new(nil, item).update?).to be false
      end
    end
  end

  describe "#edit?" do
    let(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }

    context "when user is the owner of the list" do
      it "allows access" do
        expect(subject.new(owner, item).edit?).to be true
      end
    end

    context "when user is a member of the list" do
      it "allows access" do
        expect(subject.new(member, item).edit?).to be true
      end
    end
  end

  describe "#destroy?" do
    let(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }

    context "when user is the owner of the list" do
      it "allows access" do
        expect(subject.new(owner, item).destroy?).to be true
      end
    end

    context "when user is a member of the list" do
      it "allows access" do
        expect(subject.new(member, item).destroy?).to be true
      end
    end

    context "when user is neither owner nor member" do
      it "denies access" do
        expect(subject.new(other_user, item).destroy?).to be false
      end
    end

    context "when user is nil" do
      it "denies access" do
        expect(subject.new(nil, item).destroy?).to be false
      end
    end
  end

  describe "Scope" do
    describe "#resolve" do
      let(:another_list) { create(:shopping_list, owner: other_user) }

      context "when user is present" do
        let!(:owned_item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }
        let!(:member_item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: member) }
        let!(:unrelated_item) { create(:shopping_list_item, shopping_list: another_list, added_by: other_user) }

        it "returns items from shopping lists where user is owner" do
          scope = ShoppingListItemPolicy::Scope.new(owner, ShoppingListItem).resolve
          expect(scope).to include(owned_item, member_item)
        end

        it "returns items from shopping lists where user is member" do
          scope = ShoppingListItemPolicy::Scope.new(member, ShoppingListItem).resolve
          expect(scope).to include(owned_item, member_item)
        end

        it "does not return items from shopping lists where user is neither owner nor member" do
          scope = ShoppingListItemPolicy::Scope.new(owner, ShoppingListItem).resolve
          expect(scope).not_to include(unrelated_item)
        end
      end

      context "when user is nil" do
        let!(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }

        it "returns empty scope" do
          scope = ShoppingListItemPolicy::Scope.new(nil, ShoppingListItem).resolve
          expect(scope).to be_empty
        end

        it "returns none relation" do
          scope = ShoppingListItemPolicy::Scope.new(nil, ShoppingListItem).resolve
          expect(scope).to eq(ShoppingListItem.none)
        end
      end

      context "with multiple shopping lists and items" do
        let(:list1) { create(:shopping_list, owner: owner) }
        let(:list2) { create(:shopping_list, owner: other_user) }
        let(:list3) { create(:shopping_list, owner: other_user) }

        let!(:item1) { create(:shopping_list_item, shopping_list: list1, added_by: owner) }
        let!(:item2) { create(:shopping_list_item, shopping_list: list2, added_by: other_user) }
        let!(:item3) { create(:shopping_list_item, shopping_list: list3, added_by: other_user) }

        before do
          create(:shopping_list_user, shopping_list: list2, user: owner)
        end

        it "returns all items from accessible shopping lists" do
          scope = ShoppingListItemPolicy::Scope.new(owner, ShoppingListItem).resolve
          expect(scope).to contain_exactly(item1, item2)
        end

        it "does not return items from inaccessible shopping lists" do
          scope = ShoppingListItemPolicy::Scope.new(owner, ShoppingListItem).resolve
          expect(scope).not_to include(item3)
        end
      end

      context "when shopping list has multiple items" do
        let!(:item1) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }
        let!(:item2) { create(:shopping_list_item, shopping_list: shopping_list, added_by: member) }
        let!(:item3) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }

        it "returns all items from the shopping list for owner" do
          scope = ShoppingListItemPolicy::Scope.new(owner, ShoppingListItem).resolve
          expect(scope).to contain_exactly(item1, item2, item3)
        end

        it "returns all items from the shopping list for member" do
          scope = ShoppingListItemPolicy::Scope.new(member, ShoppingListItem).resolve
          expect(scope).to contain_exactly(item1, item2, item3)
        end

        it "does not duplicate items" do
          scope = ShoppingListItemPolicy::Scope.new(owner, ShoppingListItem).resolve
          expect(scope.count).to eq(3)
        end
      end
    end
  end
end
