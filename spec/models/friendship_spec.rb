require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:friendship) { build(:friendship, requester: user1, accepter: user2) }

  describe "associations" do
    it { should belong_to(:requester).class_name('User') }
    it { should belong_to(:accepter).class_name('User') }
  end

  describe "validations" do
    it { should validate_presence_of(:requester_id) }
    it { should validate_presence_of(:accepter_id) }

    it "validates uniqueness of accepter_id scoped to requester_id" do
      create(:friendship, requester: user1, accepter: user2)
      duplicate_friendship = build(:friendship, requester: user1, accepter: user2)
      expect(duplicate_friendship).not_to be_valid
    end
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values(pending: 0, accepted: 1, blocked: 2) }
  end

  describe "scopes" do
    let!(:pending_friendship) { create(:friendship, status: :pending) }
    let!(:accepted_friendship) { create(:friendship, status: :accepted) }
    let!(:blocked_friendship) { create(:friendship, status: :blocked) }

    describe ".pending" do
      it "returns only pending friendships" do
        expect(Friendship.pending).to include(pending_friendship)
        expect(Friendship.pending).not_to include(accepted_friendship)
        expect(Friendship.pending).not_to include(blocked_friendship)
      end
    end

    describe ".accepted" do
      it "returns only accepted friendships" do
        expect(Friendship.accepted).to include(accepted_friendship)
        expect(Friendship.accepted).not_to include(pending_friendship)
        expect(Friendship.accepted).not_to include(blocked_friendship)
      end
    end

    describe ".blocked" do
      it "returns only blocked friendships" do
        expect(Friendship.blocked).to include(blocked_friendship)
        expect(Friendship.blocked).not_to include(pending_friendship)
        expect(Friendship.blocked).not_to include(accepted_friendship)
      end
    end

    describe ".between_users" do
      let!(:fs1) { create(:friendship, requester: user1, accepter: user2) }

      it "returns friendship between two users regardless of who is requester" do
        expect(Friendship.between_users(user1, user2)).to include(fs1)
        expect(Friendship.between_users(user2, user1)).to include(fs1)
      end
    end
  end
end
