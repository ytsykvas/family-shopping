# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingListPolicy, type: :policy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:member) { create(:user) }
  let(:other_user) { create(:user) }

  before do
    owner.owned_shopping_lists.destroy_all
    member.owned_shopping_lists.destroy_all
    other_user.owned_shopping_lists.destroy_all
  end

  describe "#index?" do
    context "when user is present" do
      it "allows access" do
        expect(subject.new(owner, ShoppingList).index?).to be true
      end
    end

    context "when user is nil" do
      it "denies access" do
        expect(subject.new(nil, ShoppingList).index?).to be false
      end
    end
  end

  describe "#show?" do
    context "when user is the owner" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      it "allows access" do
        expect(subject.new(owner, shopping_list).show?).to be true
      end
    end

    context "when user is a member" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      before do
        create(:shopping_list_user, shopping_list: shopping_list, user: member)
      end

      it "allows access" do
        expect(subject.new(member, shopping_list).show?).to be true
      end
    end

    context "when user is neither owner nor member" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      it "denies access" do
        expect(subject.new(other_user, shopping_list).show?).to be false
      end
    end

    context "when user is nil" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      it "denies access" do
        expect(subject.new(nil, shopping_list).show?).to be false
      end
    end
  end

  describe "#create?" do
    context "when user is present" do
      it "allows access" do
        expect(subject.new(owner, ShoppingList).create?).to be true
      end
    end

    context "when user is nil" do
      it "denies access" do
        expect(subject.new(nil, ShoppingList).create?).to be false
      end
    end
  end

  describe "#new?" do
    context "when user is present" do
      it "allows access" do
        expect(subject.new(owner, ShoppingList).new?).to be true
      end
    end

    context "when user is nil" do
      it "denies access" do
        expect(subject.new(nil, ShoppingList).new?).to be false
      end
    end
  end

  describe "#update?" do
    context "when user is the owner" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      it "allows access" do
        expect(subject.new(owner, shopping_list).update?).to be true
      end
    end

    context "when user is a member but not owner" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      before do
        create(:shopping_list_user, shopping_list: shopping_list, user: member)
      end

      it "denies access" do
        expect(subject.new(member, shopping_list).update?).to be false
      end
    end

    context "when user is neither owner nor member" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      it "denies access" do
        expect(subject.new(other_user, shopping_list).update?).to be false
      end
    end

    context "when user is nil" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      it "denies access" do
        expect(subject.new(nil, shopping_list).update?).to be false
      end
    end
  end

  describe "#edit?" do
    context "when user is the owner" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      it "allows access" do
        expect(subject.new(owner, shopping_list).edit?).to be true
      end
    end

    context "when user is a member but not owner" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      before do
        create(:shopping_list_user, shopping_list: shopping_list, user: member)
      end

      it "denies access" do
        expect(subject.new(member, shopping_list).edit?).to be false
      end
    end
  end

  describe "#destroy?" do
    context "when user is the owner" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      it "allows access" do
        expect(subject.new(owner, shopping_list).destroy?).to be true
      end
    end

    context "when user is a member but not owner" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      before do
        create(:shopping_list_user, shopping_list: shopping_list, user: member)
      end

      it "denies access" do
        expect(subject.new(member, shopping_list).destroy?).to be false
      end
    end

    context "when user is neither owner nor member" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      it "denies access" do
        expect(subject.new(other_user, shopping_list).destroy?).to be false
      end
    end

    context "when user is nil" do
      let(:shopping_list) { create(:shopping_list, owner: owner) }

      it "denies access" do
        expect(subject.new(nil, shopping_list).destroy?).to be false
      end
    end
  end

  describe "Scope" do
    describe "#resolve" do
      context "when user is present" do
        let!(:owned_list) { create(:shopping_list, owner: owner) }
        let!(:member_list) { create(:shopping_list, owner: other_user) }
        let!(:unrelated_list) { create(:shopping_list, owner: other_user) }

        before do
          create(:shopping_list_user, shopping_list: member_list, user: owner)
        end

        it "returns shopping lists where user is owner" do
          scope = ShoppingListPolicy::Scope.new(owner, ShoppingList).resolve
          expect(scope).to include(owned_list)
        end

        it "returns shopping lists where user is member" do
          scope = ShoppingListPolicy::Scope.new(owner, ShoppingList).resolve
          expect(scope).to include(member_list)
        end

        it "does not return shopping lists where user is neither owner nor member" do
          scope = ShoppingListPolicy::Scope.new(owner, ShoppingList).resolve
          expect(scope).not_to include(unrelated_list)
        end

        it "returns both owned and member lists" do
          scope = ShoppingListPolicy::Scope.new(owner, ShoppingList).resolve
          expect(scope).to contain_exactly(owned_list, member_list)
        end
      end

      context "when user is nil" do
        let!(:shopping_list) { create(:shopping_list, owner: owner) }

        it "returns empty scope" do
          scope = ShoppingListPolicy::Scope.new(nil, ShoppingList).resolve
          expect(scope).to be_empty
        end

        it "returns none relation" do
          scope = ShoppingListPolicy::Scope.new(nil, ShoppingList).resolve
          expect(scope).to eq(ShoppingList.none)
        end
      end

      context "with multiple shopping lists" do
        let(:user1) { create(:user) }
        let(:user2) { create(:user) }
        let(:user3) { create(:user) }

        let!(:list1) { create(:shopping_list, owner: owner) }
        let!(:list2) { create(:shopping_list, owner: user1) }
        let!(:list3) { create(:shopping_list, owner: user2) }
        let!(:list4) { create(:shopping_list, owner: user3) }
        let!(:unrelated1) { create(:shopping_list, owner: user1) }
        let!(:unrelated2) { create(:shopping_list, owner: user2) }

        before do
          create(:shopping_list_user, shopping_list: list2, user: owner)
          create(:shopping_list_user, shopping_list: list3, user: owner)
          create(:shopping_list_user, shopping_list: list4, user: owner)
        end

        it "returns all shopping lists where user is owner or member" do
          scope = ShoppingListPolicy::Scope.new(owner, ShoppingList).resolve
          expect(scope).to contain_exactly(list1, list2, list3, list4)
        end

        it "does not return unrelated shopping lists" do
          scope = ShoppingListPolicy::Scope.new(owner, ShoppingList).resolve
          expect(scope).not_to include(unrelated1, unrelated2)
        end
      end

      context "when user is member of multiple lists from same owner" do
        let!(:list1) { create(:shopping_list, owner: other_user) }
        let!(:list2) { create(:shopping_list, owner: other_user) }
        let!(:list3) { create(:shopping_list, owner: other_user) }

        before do
          create(:shopping_list_user, shopping_list: list1, user: owner)
          create(:shopping_list_user, shopping_list: list2, user: owner)
        end

        it "returns only lists where user is member" do
          scope = ShoppingListPolicy::Scope.new(owner, ShoppingList).resolve
          expect(scope).to contain_exactly(list1, list2)
        end

        it "does not return lists where user is not member" do
          scope = ShoppingListPolicy::Scope.new(owner, ShoppingList).resolve
          expect(scope).not_to include(list3)
        end
      end

      context "when shopping list has multiple members" do
        let!(:shopping_list) { create(:shopping_list, owner: owner) }
        let(:member1) { create(:user) }
        let(:member2) { create(:user) }
        let(:member3) { create(:user) }

        before do
          create(:shopping_list_user, shopping_list: shopping_list, user: member1)
          create(:shopping_list_user, shopping_list: shopping_list, user: member2)
          create(:shopping_list_user, shopping_list: shopping_list, user: member3)
        end

        it "returns the shopping list for owner" do
          scope = ShoppingListPolicy::Scope.new(owner, ShoppingList).resolve
          expect(scope).to include(shopping_list)
        end

        it "returns the shopping list for each member" do
          scope1 = ShoppingListPolicy::Scope.new(member1, ShoppingList).resolve
          scope2 = ShoppingListPolicy::Scope.new(member2, ShoppingList).resolve
          scope3 = ShoppingListPolicy::Scope.new(member3, ShoppingList).resolve

          expect(scope1).to include(shopping_list)
          expect(scope2).to include(shopping_list)
          expect(scope3).to include(shopping_list)
        end

        it "does not duplicate the shopping list for owner" do
          scope = ShoppingListPolicy::Scope.new(owner, ShoppingList).resolve
          expect(scope.where(id: shopping_list.id).count).to eq(1)
        end
      end
    end
  end
end
