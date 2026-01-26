require 'rails_helper'

RSpec.describe "WishlistItems", type: :request do
  let(:user) { create(:user) }
  let!(:wishlist_item) { create(:wishlist_item, user: user) }

  before do
    sign_in user
  end

  describe "GET /index" do
    it "returns http success" do
      get wishlist_items_path
      expect(response).to have_http_status(:success)
    end

    it "displays the user's wishlist items" do
      get wishlist_items_path
      expect(response.body).to include(wishlist_item.title)
    end
  end

  describe "POST /create" do
    let(:valid_attributes) do
      attributes_for(:wishlist_item, currency: "USD").except(:user)
    end

    context "with valid parameters" do
      it "creates a new WishlistItem" do
        expect {
          post wishlist_items_path, params: { wishlist_item: valid_attributes }
        }.to change(WishlistItem, :count).by(1)
      end

      it "redirects to the index page" do
        post wishlist_items_path, params: { wishlist_item: valid_attributes }
        expect(response).to redirect_to(wishlist_items_path)
      end
    end

    context "with invalid parameters" do
      it "does not create a new WishlistItem" do
        expect {
          post wishlist_items_path, params: { wishlist_item: { title: "" } }
        }.to change(WishlistItem, :count).by(0)
      end
    end
  end

  describe "PATCH /update" do
    let(:new_attributes) do
      { title: "Updated Title" }
    end

    context "with valid parameters" do
      it "updates the requested wishlist_item" do
        patch wishlist_item_path(wishlist_item), params: { wishlist_item: new_attributes }
        wishlist_item.reload
        expect(wishlist_item.title).to eq("Updated Title")
      end

      it "redirects to the index page" do
        patch wishlist_item_path(wishlist_item), params: { wishlist_item: new_attributes }
        expect(response).to redirect_to(wishlist_items_path)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested wishlist_item" do
      expect {
        delete wishlist_item_path(wishlist_item)
      }.to change(WishlistItem, :count).by(-1)
    end

    it "redirects to the wishlist_items list" do
      delete wishlist_item_path(wishlist_item)
      expect(response).to redirect_to(wishlist_items_path)
    end
  end

  describe "GET /show" do
    let(:other_user) { create(:user) }
    let!(:other_wishlist_item) { create(:wishlist_item, user: other_user) }

    it "returns http success for other user's wishlist" do
      get wishlist_item_path(other_user)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /book" do
    let(:other_user) { create(:user) }
    let!(:other_wishlist_item) { create(:wishlist_item, user: other_user) }

    context "when booking other user's item" do
      it "books the item and redirects" do
        post book_wishlist_item_path(other_wishlist_item)
        expect(response).to redirect_to(root_path) # Default fallback if no referrer
        expect(other_wishlist_item.reload).to be_booked
        expect(other_wishlist_item.booked_by_user).to eq(user)
      end

      it "creates a 'Presents' shopping list for the current user" do
        expect {
          post book_wishlist_item_path(other_wishlist_item)
        }.to change(user.owned_shopping_lists, :count).by(1)

        list = user.owned_shopping_lists.find_by(name: 'Presents')
        expect(list).to be_present
        expect(list.shopping_list_items.count).to eq(1)
        expect(list.shopping_list_items.first.name).to include(other_wishlist_item.title)
      end
    end

    context "when trying to book own item" do
      it "does not book the item" do
        post book_wishlist_item_path(wishlist_item)
        expect(wishlist_item.reload).not_to be_booked
        expect(response).to redirect_to(root_path)
      end
    end

    context "when item is already booked" do
      before { other_wishlist_item.booked! }

      it "does not re-book the item" do
        post book_wishlist_item_path(other_wishlist_item)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
