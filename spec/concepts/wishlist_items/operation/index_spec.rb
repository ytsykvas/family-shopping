# frozen_string_literal: true

require "rails_helper"

RSpec.describe WishlistItems::Operation::Index, type: :operation do
  describe "#perform!" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:user_item) { create(:wishlist_item, user: user) }
    let!(:other_item) { create(:wishlist_item, user: other_user) }

    context "viewing own wishlist" do
      it "returns user's items" do
        result = described_class.call(params: { user_id: user.id }, current_user: user)
        items = result.model.wishlist_items
        expect(items).to include(user_item)
        expect(items).not_to include(other_item)
      end

      it "sets new_wishlist_item" do
        result = described_class.call(params: { user_id: user.id }, current_user: user)
        expect(result.model.new_wishlist_item).to be_a(WishlistItem)
      end
    end

    context "viewing other user's wishlist" do
      it "returns other user's items" do
        result = described_class.call(params: { user_id: other_user.id }, current_user: user)
        items = result.model.wishlist_items
        expect(items).to include(other_item)
        expect(items).not_to include(user_item)
      end

      it "does not set new_wishlist_item" do
        result = described_class.call(params: { user_id: other_user.id }, current_user: user)
        expect(result.model.new_wishlist_item).to be_nil
      end
    end

    context "without user_id param (defaults to current user)" do
      it "returns current user's items" do
        result = described_class.call(params: {}, current_user: user)
        items = result.model.wishlist_items
        expect(items).to include(user_item)
      end
    end
  end
end
