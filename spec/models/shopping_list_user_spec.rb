# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingListUser, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:shopping_list) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { build(:shopping_list_user) }

    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:shopping_list_id) }

    describe "shopping_list association" do
      let(:shopping_list) { create(:shopping_list) }
      let(:user) { create(:user) }
      let(:list_user) { create(:shopping_list_user, shopping_list: shopping_list, user: user) }

      it "belongs to a shopping list" do
        expect(list_user.shopping_list).to eq(shopping_list)
      end

      it "requires a shopping list" do
        list_user.shopping_list = nil
        expect(list_user).not_to be_valid
      end
    end

    describe "user association" do
      let(:shopping_list) { create(:shopping_list) }
      let(:user) { create(:user) }
      let(:list_user) { create(:shopping_list_user, shopping_list: shopping_list, user: user) }

      it "belongs to a user" do
        expect(list_user.user).to eq(user)
      end

      it "requires a user" do
        list_user.user = nil
        expect(list_user).not_to be_valid
      end
    end
  end

  describe "factory" do
    it "creates a valid shopping list user" do
      list_user = build(:shopping_list_user)
      expect(list_user).to be_valid
    end

    it "creates a shopping list user with all required attributes" do
      list_user = create(:shopping_list_user)
      expect(list_user.shopping_list).to be_present
      expect(list_user.user).to be_present
    end
  end

  describe "uniqueness" do
    let(:shopping_list) { create(:shopping_list) }
    let(:user) { create(:user) }

    context "when user is already added to shopping list" do
      before do
        create(:shopping_list_user, shopping_list: shopping_list, user: user)
      end

      it "does not allow duplicate user in same shopping list" do
        duplicate_list_user = build(:shopping_list_user, shopping_list: shopping_list, user: user)
        expect(duplicate_list_user).not_to be_valid
      end
    end

    context "when user is added to different shopping list" do
      let(:another_shopping_list) { create(:shopping_list) }

      before do
        create(:shopping_list_user, shopping_list: shopping_list, user: user)
      end

      it "allows same user in different shopping list" do
        list_user = build(:shopping_list_user, shopping_list: another_shopping_list, user: user)
        expect(list_user).to be_valid
      end
    end

    context "when different user is added to same shopping list" do
      let(:another_user) { create(:user) }

      before do
        create(:shopping_list_user, shopping_list: shopping_list, user: user)
      end

      it "allows different user in same shopping list" do
        list_user = build(:shopping_list_user, shopping_list: shopping_list, user: another_user)
        expect(list_user).to be_valid
      end
    end
  end

  describe "multiple users per shopping list" do
    let(:shopping_list) { create(:shopping_list) }
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user3) { create(:user) }

    it "allows multiple users to be added to same shopping list" do
      list_user1 = create(:shopping_list_user, shopping_list: shopping_list, user: user1)
      list_user2 = create(:shopping_list_user, shopping_list: shopping_list, user: user2)
      list_user3 = create(:shopping_list_user, shopping_list: shopping_list, user: user3)

      expect(shopping_list.shopping_list_users).to include(list_user1, list_user2, list_user3)
      expect(shopping_list.members).to include(user1, user2, user3)
    end
  end

  describe "multiple shopping lists per user" do
    let(:user) { create(:user) }
    let(:list1) { create(:shopping_list) }
    let(:list2) { create(:shopping_list) }
    let(:list3) { create(:shopping_list) }

    it "allows user to be added to multiple shopping lists" do
      list_user1 = create(:shopping_list_user, shopping_list: list1, user: user)
      list_user2 = create(:shopping_list_user, shopping_list: list2, user: user)
      list_user3 = create(:shopping_list_user, shopping_list: list3, user: user)

      expect(user.shopping_list_users).to include(list_user1, list_user2, list_user3)
    end
  end
end
