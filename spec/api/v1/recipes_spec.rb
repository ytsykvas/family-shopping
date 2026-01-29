require 'rails_helper'

RSpec.describe V1::Recipes, type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:recipe) { create(:recipe, user: user) }
  let!(:ingredient) { create(:ingredient, recipe: recipe, content: "Eggs 2pcs") }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v1/recipes" do
    it "returns the user's recipes" do
      get "/api/v1/recipes", headers: headers
      expect(response).to have_http_status(:success)
      expect(json.size).to eq(1)
      expect(json.first["id"]).to eq(recipe.id)
      expect(json.first["ingredients"].size).to eq(1)
    end
  end

  describe "GET /api/v1/recipes/:id" do
    it "returns the recipe" do
      get "/api/v1/recipes/#{recipe.id}", headers: headers
      expect(response).to have_http_status(:success)
      expect(json["id"]).to eq(recipe.id)
    end

    it "returns 404 for non-existent recipe" do
      get "/api/v1/recipes/999999", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/recipes" do
    let(:valid_params) do
      {
        recipe: {
          name: "New Recipe",
          description: "Delicious",
          ingredients_attributes: [
            { content: "Milk 1L" }
          ]
        }
      }
    end

    it "creates a new recipe" do
      expect {
        post "/api/v1/recipes", params: valid_params.to_json, headers: headers
      }.to change(Recipe, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(json["name"]).to eq("New Recipe")
      expect(json["ingredients"].size).to eq(1)
    end

    it "returns validation errors" do
      post "/api/v1/recipes", params: { recipe: { name: "" } }.to_json, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PUT /api/v1/recipes/:id" do
    it "updates the recipe" do
      put "/api/v1/recipes/#{recipe.id}", params: { recipe: { name: "Updated Name" } }.to_json, headers: headers
      expect(response).to have_http_status(:success)
      expect(recipe.reload.name).to eq("Updated Name")
    end

    it "updates ingredients" do
      put "/api/v1/recipes/#{recipe.id}", params: {
        recipe: {
          ingredients_attributes: [
            { id: ingredient.id, content: "Eggs 3pcs" }
          ]
        }
      }.to_json, headers: headers

      expect(response).to have_http_status(:success)
      expect(ingredient.reload.content).to eq("Eggs 3pcs")
    end

    it "returns 403 when updating other's recipe" do
      other_recipe = create(:recipe, user: other_user)
      put "/api/v1/recipes/#{other_recipe.id}", params: { recipe: { name: "Hacked" } }.to_json, headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/recipes/:id" do
    it "deletes the recipe" do
      expect {
        delete "/api/v1/recipes/#{recipe.id}", headers: headers
      }.to change(Recipe, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "returns 403 when deleting other's recipe" do
      other_recipe = create(:recipe, user: other_user)
      delete "/api/v1/recipes/#{other_recipe.id}", headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/recipes/:id/add_to_shopping_list" do
    before do
      # Ensure Home list exists
      user.owned_shopping_lists.find_or_create_by(name: "Home")
    end

    it "adds ingredients to shopping list" do
      post "/api/v1/recipes/#{recipe.id}/add_to_shopping_list", params: { ingredient_ids: [ ingredient.id ] }.to_json, headers: headers
      expect(response).to have_http_status(:success)

      home_list = user.owned_shopping_lists.find_by(name: "Home")
      expect(home_list.shopping_list_items.where(name: "Eggs 2pcs")).to exist
    end
  end
end
