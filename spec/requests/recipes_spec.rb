require 'rails_helper'

RSpec.describe "Recipes", type: :request do
  let(:user) { create(:user) }
  let(:recipe) { create(:recipe, user: user) }
  let!(:ingredient) { create(:ingredient, recipe: recipe, content: "Eggs 2pcs") }

  before do
    sign_in user
  end

  describe "GET /recipes" do
    it "returns http success" do
      get recipes_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /recipes/:id" do
    it "returns http success" do
      get recipe_path(recipe)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /recipes" do
    let(:valid_params) do
      {
        recipe: {
          name: "New Recipe",
          description: "This is a delicious new recipe",
          ingredients_attributes: [
            { content: "Milk 1L" }
          ]
        }
      }
    end

    it "creates a new recipe with a description" do
      expect {
        post recipes_path, params: valid_params
      }.to change(Recipe, :count).by(1)

      expect(Recipe.last.description).to eq("This is a delicious new recipe")
    end

    it "creates ingredients" do
      expect {
        post recipes_path, params: valid_params
      }.to change(Ingredient, :count).by(1)
    end
  end

  describe "GET /recipes/:id/edit" do
    it "returns http success" do
      get edit_recipe_path(recipe)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /recipes/:id" do
    let(:update_params) do
      {
        recipe: {
          name: "Updated Recipe",
          description: "Updated description"
        }
      }
    end

    it "updates the recipe" do
      patch recipe_path(recipe), params: update_params
      recipe.reload
      expect(recipe.name).to eq("Updated Recipe")
      expect(recipe.description).to eq("Updated description")
      expect(response).to redirect_to(recipe_path(recipe))
    end
  end

  describe "DELETE /recipes/:id" do
    it "destroys the recipe" do
      recipe_to_delete = create(:recipe, user: user)
      expect {
        delete recipe_path(recipe_to_delete)
      }.to change(Recipe, :count).by(-1)
    end
  end

  describe "POST /recipes/:id/add_to_shopping_list" do
    before do
      # Ensure Home list exists (though it should by default)
      user.owned_shopping_lists.find_or_create_by(name: "Home")
    end

    context "with ingredient_ids" do
      it "adds selected ingredients to Home shopping list" do
        post add_to_shopping_list_recipe_path(recipe), params: { ingredient_ids: [ ingredient.id ] }

        home_list = user.owned_shopping_lists.find_by(name: "Home")
        expect(home_list.shopping_list_items.where(name: "Eggs 2pcs")).to exist
      end
    end

    context "without ingredient_ids" do
      it "redirects with alert" do
        post add_to_shopping_list_recipe_path(recipe), params: { ingredient_ids: [] }
        expect(response).to redirect_to(recipe_path(recipe))
        expect(flash[:alert]).to be_present
      end
    end
  end
end
