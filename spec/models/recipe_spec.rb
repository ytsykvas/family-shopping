require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:ingredients).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:ingredients).allow_destroy(true) }

    it { is_expected.to belong_to(:original_recipe).class_name("Recipe").optional.counter_cache(:copies_count) }
    it { is_expected.to have_many(:copies).class_name("Recipe").with_foreign_key(:original_recipe_id).dependent(:nullify) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "factory" do
    it "creates a valid recipe" do
      expect(build(:recipe)).to be_valid
    end
  end
end
