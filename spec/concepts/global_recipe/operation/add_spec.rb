require 'rails_helper'

RSpec.describe GlobalRecipe::Operation::Add do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:original_recipe) { create(:recipe, :with_ingredients, user: other_user, name: "Original Recipe", copies_count: 5) }

  subject { described_class.call(params: { id: original_recipe.id }, current_user: user) }

  it "creates a copy of the recipe for the current user" do
    expect { subject }.to change(Recipe, :count).by(1)

    new_recipe = subject.model
    expect(new_recipe.user).to eq(user)
    expect(new_recipe.name).to eq(original_recipe.name)
    expect(new_recipe.original_recipe).to eq(original_recipe)
    expect(new_recipe.copies_count).to eq(0)
  end

  it "copies ingredients" do
    expect { subject }.to change(Ingredient, :count).by(original_recipe.ingredients.count)

    new_recipe = subject.model
    new_recipe.ingredients.each do |ingredient|
      expect(ingredient.recipe).to eq(new_recipe)
    end
  end

  it "increments copies_count on the original recipe" do
    expect { subject }.to change { original_recipe.reload.copies_count }.by(1)
  end
end
