require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:recipe) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:content) }
  end

  describe "factory" do
    it "creates a valid ingredient" do
      expect(build(:ingredient)).to be_valid
    end
  end
end
