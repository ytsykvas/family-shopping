# frozen_string_literal: true

require "rails_helper"

RSpec.describe FriendshipPolicy, type: :policy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:third_user) { create(:user) }

  describe "#index?" do
    context "when user is present" do
      it "allows access" do
        expect(subject.new(user, Friendship).index?).to be true
      end
    end

    context "when user is nil" do
      it "denies access" do
        expect(subject.new(nil, Friendship).index?).to be false
      end
    end
  end

  describe "Scope" do
    describe "#resolve" do
      context "when user is present" do
        let!(:friendship_as_requester) { create(:friendship, requester: user, accepter: other_user) }
        let!(:friendship_as_accepter) { create(:friendship, requester: other_user, accepter: user) }
        let!(:unrelated_friendship) { create(:friendship, requester: other_user, accepter: third_user) }

        it "returns friendships where user is requester" do
          scope = FriendshipPolicy::Scope.new(user, Friendship).resolve
          expect(scope).to include(friendship_as_requester)
        end

        it "returns friendships where user is accepter" do
          scope = FriendshipPolicy::Scope.new(user, Friendship).resolve
          expect(scope).to include(friendship_as_accepter)
        end

        it "does not return friendships where user is not involved" do
          scope = FriendshipPolicy::Scope.new(user, Friendship).resolve
          expect(scope).not_to include(unrelated_friendship)
        end

        it "returns both friendships where user is requester or accepter" do
          scope = FriendshipPolicy::Scope.new(user, Friendship).resolve
          expect(scope).to contain_exactly(friendship_as_requester, friendship_as_accepter)
        end
      end

      context "when user is nil" do
        it "returns empty scope" do
          scope = FriendshipPolicy::Scope.new(nil, Friendship).resolve
          expect(scope).to be_empty
        end

        it "returns none relation" do
          scope = FriendshipPolicy::Scope.new(nil, Friendship).resolve
          expect(scope).to eq(Friendship.none)
        end
      end

      context "with different statuses" do
        let(:fourth_user) { create(:user) }
        let(:fifth_user) { create(:user) }
        let!(:pending_friendship) { create(:friendship, :pending, requester: user, accepter: fourth_user) }
        let!(:accepted_friendship) { create(:friendship, :accepted, requester: user, accepter: fifth_user) }
        let!(:blocked_friendship) { create(:friendship, :blocked, requester: fourth_user, accepter: user) }

        it "returns friendships with any status where user is involved" do
          scope = FriendshipPolicy::Scope.new(user, Friendship).resolve
          expect(scope).to include(pending_friendship, accepted_friendship, blocked_friendship)
        end
      end

      context "with multiple friendships" do
        let(:fourth_user) { create(:user) }
        let(:fifth_user) { create(:user) }
        let(:sixth_user) { create(:user) }
        let!(:friendship1) { create(:friendship, requester: user, accepter: fourth_user) }
        let!(:friendship2) { create(:friendship, requester: fifth_user, accepter: user) }
        let!(:friendship3) { create(:friendship, requester: user, accepter: sixth_user) }
        let!(:friendship4) { create(:friendship, requester: sixth_user, accepter: user) }
        let!(:unrelated1) { create(:friendship, requester: fourth_user, accepter: fifth_user) }
        let!(:unrelated2) { create(:friendship, requester: fifth_user, accepter: sixth_user) }

        it "returns all friendships where user is involved" do
          scope = FriendshipPolicy::Scope.new(user, Friendship).resolve
          expect(scope).to contain_exactly(friendship1, friendship2, friendship3, friendship4)
        end

        it "does not return unrelated friendships" do
          scope = FriendshipPolicy::Scope.new(user, Friendship).resolve
          expect(scope).not_to include(unrelated1, unrelated2)
        end
      end
    end
  end
end
