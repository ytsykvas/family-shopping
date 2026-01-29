require 'rails_helper'

RSpec.describe GlobalRecipesController, type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:recipe) { create(:recipe, user: other_user) }

  before { sign_in user }

  describe "GET /global_recipes" do
    it "returns success" do
      get global_recipes_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /global_recipes/:id" do
    it "returns success" do
      get global_recipe_path(recipe)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /global_recipes/:id/add" do
    it "adds recipe and redirects" do
      post add_global_recipe_path(recipe)
      expect(response).to redirect_to(recipes_path)
      follow_redirect!
      expect(flash[:notice]).to be_present
    end
  end
end
