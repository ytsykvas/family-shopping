# frozen_string_literal: true

require "rails_helper"

RSpec.describe WishlistItems::Operation::Unbook, type: :operation do
  describe "#perform!" do
    let!(:owner) { create(:user, nickname: "OwnerGuy") }
    let!(:booker) { create(:user, nickname: "BookerGuy") }
    let(:other_user) { create(:user) }
    # Setup: item booked by booker
    let!(:wishlist_item) { create(:wishlist_item, :booked, title: "MyItem", user: owner, booked_by_user: booker) }

    # Setup: 'Presents' list with the item (use existing list created by user callback)
    let!(:presents_list) { booker.owned_shopping_lists.find_by(name: "Presents") }
    let!(:list_item) do
      create(:shopping_list_item,
        shopping_list: presents_list,
        name: "#{wishlist_item.title} (#{wishlist_item.user.nickname})",
        added_by: booker
      )
    end

    let(:params) { { id: wishlist_item.id } }

    context "when valid (unbooking own booking)" do
      it "marks the item as pending (unbooked)" do
        described_class.call(params: params, current_user: booker)
        wishlist_item.reload
        expect(wishlist_item.status).to eq("pending")
        expect(wishlist_item.booked_by_user).to be_nil
      end

      it "removes the item from 'Presents' shopping list" do
        expect do
          described_class.call(params: params, current_user: booker)
        end.to change(ShoppingListItem, :count).by(-1)

        expect(presents_list.shopping_list_items.where(name: list_item.name)).to be_empty
      end

      it "returns success" do
        result = described_class.call(params: params, current_user: booker)
        expect(result).to be_success
      end
    end

    context "when unbooking someone else's booking" do
      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: other_user)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
