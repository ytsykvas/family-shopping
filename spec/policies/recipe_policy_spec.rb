require 'rails_helper'

RSpec.describe RecipePolicy, type: :policy do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:recipe) { create(:recipe, user: user) }

  subject { described_class.new(user, recipe) }

  describe 'actions' do
    context 'for a user who owns the recipe' do
      it 'permits show' do expect(subject.show?).to be true end
      it 'permits update' do expect(subject.update?).to be true end
      it 'permits destroy' do expect(subject.destroy?).to be true end
      it 'permits add_to_shopping_list' do expect(subject.add_to_shopping_list?).to be true end
    end

    context 'for a user who does not own the recipe' do
      subject { described_class.new(other_user, recipe) }

      it 'forbids show' do expect(subject.show?).to be false end
      it 'forbids update' do expect(subject.update?).to be false end
      it 'forbids destroy' do expect(subject.destroy?).to be false end
      it 'forbids add_to_shopping_list' do expect(subject.add_to_shopping_list?).to be false end
    end

    context 'general permissions' do
      it 'permits index' do expect(subject.index?).to be true end
      it 'permits create' do expect(subject.create?).to be true end
    end
  end

  describe RecipePolicy::Scope do
    let!(:user_recipe) { create(:recipe, user: user) }
    let!(:other_recipe) { create(:recipe, user: other_user) }

    subject { described_class.new(user, Recipe).resolve }

    it 'includes recipes owned by the user' do
      expect(subject).to include(user_recipe)
    end

    it 'excludes recipes owned by others' do
      expect(subject).not_to include(other_recipe)
    end
  end
end
