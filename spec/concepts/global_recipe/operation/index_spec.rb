require 'rails_helper'

RSpec.describe GlobalRecipe::Operation::Index do
  let(:user) { create(:user) }
  let!(:my_recipe) { create(:recipe, user: user, name: "Pizza") }
  let!(:other_user) { create(:user) }
  let!(:other_recipe) { create(:recipe, :with_ingredients, user: other_user, name: "Pasta") }
  let!(:other_recipe_2) { create(:recipe, user: other_user, name: "Burger") }

  subject { described_class.call(params: params, current_user: user) }

  context "when no filters are applied" do
    let(:params) { {} }

    it "returns all recipes except current user's" do
      expect(subject.success?).to be_truthy
      recipes = subject.model.global_recipes
      expect(recipes).to include(other_recipe)
      expect(recipes).to include(other_recipe_2)
      expect(recipes).not_to include(my_recipe)
    end
  end

  context "when filtering by name" do
    let(:params) { { name: "Pasta" } }

    it "returns matching recipes" do
      expect(subject.success?).to be_truthy
      recipes = subject.model.global_recipes
      expect(recipes).to include(other_recipe)
      expect(recipes).not_to include(other_recipe_2)
    end
  end

  context "when filtering by ingredient" do
    let(:params) { { ingredient: other_recipe.ingredients.first.content } }

    it "returns matching recipes" do
      expect(subject.success?).to be_truthy
      recipes = subject.model.global_recipes
      expect(recipes).to include(other_recipe)
      expect(recipes).not_to include(other_recipe_2)
    end
  end
end
