require "rails_helper"

RSpec.describe "ShoppingListItems", type: :request do
  let(:user) { create(:user) }
  let(:member) { create(:user) }
  let(:other_user) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: user) }
  let(:headers) { authenticated_header(user) }
  let(:member_headers) { authenticated_header(member) }

  before do
    create(:shopping_list_user, shopping_list: shopping_list, user: member)
  end

  describe "GET /api/v1/shopping_lists/:shopping_list_id/items" do
    let!(:item1) { create(:shopping_list_item, shopping_list: shopping_list, added_by: user, name: "Milk") }
    let!(:item2) { create(:shopping_list_item, :done, shopping_list: shopping_list, added_by: member, name: "Bread") }

    it "returns all items for owner" do
      get "/api/v1/shopping_lists/#{shopping_list.id}/items", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json.count).to eq(2)
      expect(json.map { |i| i["name"] }).to contain_exactly("Milk", "Bread")
    end

    it "returns all items for member" do
      get "/api/v1/shopping_lists/#{shopping_list.id}/items", headers: member_headers

      expect(response).to have_http_status(:ok)
      expect(json.count).to eq(2)
    end

    it "includes item status and added_by" do
      get "/api/v1/shopping_lists/#{shopping_list.id}/items", headers: headers

      milk_item = json.find { |i| i["name"] == "Milk" }
      expect(milk_item["status"]).to eq("pending")
      expect(milk_item["added_by"]["id"]).to eq(user.id)
    end

    context "when not authorized" do
      let(:unauthorized_headers) { authenticated_header(other_user) }

      it "returns 403" do
        get "/api/v1/shopping_lists/#{shopping_list.id}/items", headers: unauthorized_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /api/v1/shopping_lists/:shopping_list_id/items" do
    let(:valid_params) { { shopping_list_item: { name: "Eggs" } } }

    it "creates a new item for owner" do
      expect {
        post "/api/v1/shopping_lists/#{shopping_list.id}/items",
             params: valid_params.to_json,
             headers: headers
      }.to change(ShoppingListItem, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("Eggs")
      expect(json["status"]).to eq("pending")
      expect(json["added_by"]["id"]).to eq(user.id)
    end

    it "creates a new item for member" do
      expect {
        post "/api/v1/shopping_lists/#{shopping_list.id}/items",
             params: valid_params.to_json,
             headers: member_headers
      }.to change(ShoppingListItem, :count).by(1)

      expect(json["added_by"]["id"]).to eq(member.id)
    end

    context "when not authorized" do
      let(:unauthorized_headers) { authenticated_header(other_user) }

      it "returns 403" do
        post "/api/v1/shopping_lists/#{shopping_list.id}/items",
             params: valid_params.to_json,
             headers: unauthorized_headers

        expect(response).to have_http_status(:forbidden)
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { shopping_list_item: { name: "" } } }

      it "returns 422" do
        post "/api/v1/shopping_lists/#{shopping_list.id}/items",
             params: invalid_params.to_json,
             headers: headers

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /api/v1/shopping_lists/:shopping_list_id/items/:id" do
    let!(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: user, name: "Milk") }

    it "updates item name" do
      patch "/api/v1/shopping_lists/#{shopping_list.id}/items/#{item.id}",
            params: { shopping_list_item: { name: "Almond Milk" } }.to_json,
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["name"]).to eq("Almond Milk")
    end

    it "updates item status to done" do
      patch "/api/v1/shopping_lists/#{shopping_list.id}/items/#{item.id}",
            params: { shopping_list_item: { status: "done" } }.to_json,
            headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["status"]).to eq("done")
    end

    it "sets edited_by to current user" do
      patch "/api/v1/shopping_lists/#{shopping_list.id}/items/#{item.id}",
            params: { shopping_list_item: { name: "Updated" } }.to_json,
            headers: member_headers

      expect(response).to have_http_status(:ok)
      expect(json["edited_by"]["id"]).to eq(member.id)
    end

    context "when not authorized" do
      let(:unauthorized_headers) { authenticated_header(other_user) }

      it "returns 403" do
        patch "/api/v1/shopping_lists/#{shopping_list.id}/items/#{item.id}",
              params: { shopping_list_item: { name: "Hacked" } }.to_json,
              headers: unauthorized_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/v1/shopping_lists/:shopping_list_id/items/:id" do
    let!(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: user) }

    it "deletes the item for owner" do
      expect {
        delete "/api/v1/shopping_lists/#{shopping_list.id}/items/#{item.id}", headers: headers
      }.to change(ShoppingListItem, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "deletes the item for member" do
      expect {
        delete "/api/v1/shopping_lists/#{shopping_list.id}/items/#{item.id}", headers: member_headers
      }.to change(ShoppingListItem, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    context "when not authorized" do
      let(:unauthorized_headers) { authenticated_header(other_user) }

      it "returns 403" do
        delete "/api/v1/shopping_lists/#{shopping_list.id}/items/#{item.id}",
               headers: unauthorized_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
