# frozen_string_literal: true

require "rails_helper"

RSpec.describe WishlistItems::Operation::Show, type: :operation do
  describe "#perform!" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:other_item) { create(:wishlist_item, user: other_user) }

    it "loads the target user items" do
      result = described_class.call(params: { id: other_user.id }, current_user: user)
      items = result.model.wishlist_items
      expect(items).to include(other_item)
      expect(result.model.target_user).to eq(other_user)
    end
  end
end
