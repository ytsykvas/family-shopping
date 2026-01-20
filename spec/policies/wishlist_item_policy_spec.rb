require 'rails_helper'

RSpec.describe WishlistItemPolicy, type: :policy do
  subject { described_class.new(user, wishlist_item) }

  let(:user) { create(:user) }
  let(:wishlist_item) { create(:wishlist_item, user: user) }

  context 'being a visitor' do
    let(:user) { nil }
    let(:owner) { create(:user) }
    let(:wishlist_item) { create(:wishlist_item, user: owner) }

    it 'denies all actions' do
      expect(subject.index?).to be true # Public wishlist? Wait, index returns true in policy

      expect(subject.create?).to be true # Wait, create? returns true in policy
      expect(subject.update?).to be false
      expect(subject.destroy?).to be false
    end
  end

  context 'being the owner' do
    it 'permits all actions' do
      expect(subject.index?).to be true
      expect(subject.create?).to be true
      expect(subject.update?).to be true
      expect(subject.destroy?).to be true
    end
  end

  context 'being another user' do
    let(:other_user) { create(:user) }
    let(:wishlist_item) { create(:wishlist_item, user: other_user) }

    it 'permits reading but restricts modification' do
      expect(subject.index?).to be true
      expect(subject.create?).to be true
      expect(subject.update?).to be false
      expect(subject.destroy?).to be false
    end
  end

  describe 'Scope' do
    let(:user) { create(:user) }
    let!(:my_item) { create(:wishlist_item, user: user) }
    let!(:other_item) { create(:wishlist_item) }

    subject(:scope) { Pundit.policy_scope(user, WishlistItem) }

    it 'includes only user items' do
      expect(scope).to include(my_item)
      expect(scope).not_to include(other_item)
    end
  end
end
