# frozen_string_literal: true

require "rails_helper"

RSpec.describe WishlistItems::Operation::Book, type: :operation do
  describe "#perform!" do
    let!(:owner) { create(:user) }
    let!(:booker) { create(:user) }
    let(:wishlist_item) { create(:wishlist_item, user: owner) }
    let(:params) { { id: wishlist_item.id } }

    context "when valid" do
      it "marks the item as booked" do
        described_class.call(params: params, current_user: booker)
        expect(wishlist_item.reload).to be_booked
        expect(wishlist_item.booked_by_user).to eq(booker)
      end

      it "adds the item to 'Presents' shopping list" do
        expect do
          described_class.call(params: params, current_user: booker)
        end.to change(ShoppingList, :count).by(0)

        list = booker.owned_shopping_lists.find_by(name: "Presents")
        expect(list.shopping_list_items.last.name).to include(wishlist_item.title)
      end

      it "returns success" do
         result = described_class.call(params: params, current_user: booker)
         expect(result).to be_success
      end
    end

    context "when booking own item" do
      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: owner)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when already booked" do
      before { wishlist_item.update!(status: :booked, booked_by_user: create(:user)) }

      it "returns failure" do
        result = described_class.call(params: params, current_user: booker)
        expect(result).to be_failure
        expect(result.errors.full_messages).to include(I18n.t("wishlist_items.book.errors.already_booked"))
      end
    end
  end
end
