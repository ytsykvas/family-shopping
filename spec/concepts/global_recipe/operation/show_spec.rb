require 'rails_helper'

RSpec.describe GlobalRecipe::Operation::Show do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:recipe) { create(:recipe, user: other_user) }

  subject { described_class.call(params: { id: recipe.id }, current_user: user) }

  it "returns the recipe" do
    expect(subject.success?).to be_truthy
    expect(subject.model).to eq(recipe)
  end

  context "when recipe does not exist" do
    subject { described_class.call(params: { id: -1 }, current_user: user) }

    it "raises ActiveRecord::RecordNotFound" do
      expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
