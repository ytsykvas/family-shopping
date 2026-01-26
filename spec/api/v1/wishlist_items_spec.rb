require 'rails_helper'

RSpec.describe V1::WishlistItems, type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:wishlist_item) { create(:wishlist_item, user: user) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v1/wishlist_items" do
    it "returns the user's wishlist" do
      get "/api/v1/wishlist_items", headers: headers
      expect(response).to have_http_status(:success)
      expect(json.size).to eq(1)
      expect(json.first["id"]).to eq(wishlist_item.id)
    end
  end

  describe "GET /api/v1/wishlist_items/:id" do
    let!(:other_item) { create(:wishlist_item, user: other_user) }

    it "returns the wishlist of another user" do
      get "/api/v1/wishlist_items/#{other_user.id}", headers: headers
      expect(response).to have_http_status(:success)
      expect(json.first["id"]).to eq(other_item.id)
    end
  end

  describe "POST /api/v1/wishlist_items" do
    let(:valid_params) { { wishlist_item: { title: "New Item", description: "Desc", price: 100 } } }

    it "creates a new wishlist item" do
      expect {
        post "/api/v1/wishlist_items", params: valid_params.to_json, headers: headers
      }.to change(WishlistItem, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(json["title"]).to eq("New Item")
    end

    it "returns validation errors" do
      post "/api/v1/wishlist_items", params: { wishlist_item: { title: "" } }.to_json, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PUT /api/v1/wishlist_items/:id" do
    it "updates the wishlist item" do
      put "/api/v1/wishlist_items/#{wishlist_item.id}", params: { wishlist_item: { title: "Updated Title" } }.to_json, headers: headers
      expect(response).to have_http_status(:success)
      expect(wishlist_item.reload.title).to eq("Updated Title")
    end

    it "returns 403 when updating other's item" do
      other_item = create(:wishlist_item, user: other_user)
      put "/api/v1/wishlist_items/#{other_item.id}", params: { wishlist_item: { title: "Hacked" } }.to_json, headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/wishlist_items/:id" do
      it "deletes the wishlist item" do
        expect {
          delete "/api/v1/wishlist_items/#{wishlist_item.id}", headers: headers
        }.to change(WishlistItem, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
  end

  describe "POST /api/v1/wishlist_items/:id/book" do
      let(:other_item) { create(:wishlist_item, user: other_user) }

      it "books the item" do
        post "/api/v1/wishlist_items/#{other_item.id}/book", headers: headers
        expect(response).to have_http_status(:success)
        expect(other_item.reload).to be_booked
        expect(other_item.booked_by_user).to eq(user)
      end

      it "returns error if trying to book own item" do
        post "/api/v1/wishlist_items/#{wishlist_item.id}/book", headers: headers
        expect(response).to have_http_status(:forbidden)
      end
  end

  describe "DELETE /api/v1/wishlist_items/:id/unbook" do
      let(:other_item) { create(:wishlist_item, user: other_user, status: :booked, booked_by_user: user) }

      it "unbooks the item" do
        delete "/api/v1/wishlist_items/#{other_item.id}/unbook", headers: headers
        expect(response).to have_http_status(:success)
        expect(other_item.reload).not_to be_booked
        expect(other_item.booked_by_user).to be_nil
      end
  end
end
