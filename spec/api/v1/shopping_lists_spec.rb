require "rails_helper"

RSpec.describe "ShoppingLists", type: :request do
  let(:user) { create(:user) }
  let(:headers) { authenticated_header(user) }

  describe "GET /api/v1/shopping_lists" do
    let!(:shopping_list) { create(:shopping_list, owner: user) }
    let!(:other_shopping_list) { create(:shopping_list) }

    it "returns user's shopping lists" do
      get "/api/v1/shopping_lists", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["shopping_lists"].count).to eq(1)
      expect(json["shopping_lists"].first["id"]).to eq(shopping_list.id)
    end
  end

  describe "POST /api/v1/shopping_lists" do
    it "creates a new shopping list" do
      expect {
        post "/api/v1/shopping_lists",
             params: { shopping_list: { name: "New List" } }.to_json,
             headers: headers
      }.to change(ShoppingList, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("New List")
      expect(json["owner"]["id"]).to eq(user.id)
    end
  end

  describe "GET /api/v1/shopping_lists/:id" do
    let(:shopping_list) { create(:shopping_list, owner: user) }

    it "returns the shopping list" do
      get "/api/v1/shopping_lists/#{shopping_list.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(shopping_list.id)
    end

    context "when not authorized" do
      let(:other_list) { create(:shopping_list) }

      it "returns 403" do
        get "/api/v1/shopping_lists/#{other_list.id}", headers: headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PUT /api/v1/shopping_lists/:id" do
    let(:shopping_list) { create(:shopping_list, owner: user) }

    it "updates the shopping list" do
      put "/api/v1/shopping_lists/#{shopping_list.id}",
          params: { shopping_list: { name: "Updated Name" } }.to_json,
          headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["name"]).to eq("Updated Name")
    end
  end

  describe "DELETE /api/v1/shopping_lists/:id" do
    let!(:shopping_list) { create(:shopping_list, owner: user) }

    it "deletes the shopping list" do
      expect {
        delete "/api/v1/shopping_lists/#{shopping_list.id}", headers: headers
      }.to change(ShoppingList, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
