# frozen_string_literal: true

require "rails_helper"

RSpec.describe FriendshipRequest::Operation::Index, type: :operation do
  describe "#perform!" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:third_user) { create(:user) }
    let(:fourth_user) { create(:user) }
    let(:params) { {} }

    context "when user is authorized" do
      let!(:pending_friendship1) { create(:friendship, :pending, requester: user, accepter: other_user) }
      let!(:pending_friendship2) { create(:friendship, :pending, requester: third_user, accepter: user) }
      let!(:accepted_friendship) { create(:friendship, :accepted, requester: user, accepter: fourth_user) }
      let!(:blocked_friendship) { create(:friendship, :blocked, requester: fourth_user, accepter: user) }
      let!(:unrelated_friendship) { create(:friendship, :pending, requester: other_user, accepter: third_user) }

      it "returns successful result" do
        result = described_class.call(params: params, current_user: user)
        expect(result).to be_success
      end

      it "calls authorize! with Friendship and :index?" do
        operation = described_class.new(params: params, current_user: user)
        expect(operation).to receive(:authorize!).with(Friendship, :index?)
        operation.call
      end

      it "uses policy_scope to filter friendships" do
        operation = described_class.new(params: params, current_user: user)
        expect(operation).to receive(:policy_scope).with(Friendship).and_call_original
        operation.call
      end

      it "returns only pending friendships where user is involved" do
        result = described_class.call(params: params, current_user: user)
        friendships = result.model

        expect(friendships).to include(pending_friendship1, pending_friendship2)
        expect(friendships).not_to include(accepted_friendship, blocked_friendship, unrelated_friendship)
      end

      it "includes requester and accepter associations" do
        result = described_class.call(params: params, current_user: user)
        friendships = result.model.to_a

        friendships.each do |friendship|
          expect(friendship.association(:requester).loaded?).to be true
          expect(friendship.association(:accepter).loaded?).to be true
        end
      end

      it "sets model in result" do
        result = described_class.call(params: params, current_user: user)
        expect(result.model).to be_present
        expect(result.model).to be_a(ActiveRecord::Relation)
      end

      it "marks pundit authorization as called" do
        result = described_class.call(params: params, current_user: user)
        expect(result[:pundit]).to be true
      end

      it "marks pundit scope as called" do
        result = described_class.call(params: params, current_user: user)
        expect(result[:pundit_scope]).to be true
      end

      context "when user has no pending friendship requests" do
        let(:user_without_requests) { create(:user) }

        it "returns empty collection" do
          result = described_class.call(params: params, current_user: user_without_requests)
          expect(result.model).to be_empty
        end
      end

      context "with multiple pending friendships" do
        let(:fifth_user) { create(:user) }
        let(:sixth_user) { create(:user) }
        let!(:friendship3) { create(:friendship, :pending, requester: user, accepter: fifth_user) }
        let!(:friendship4) { create(:friendship, :pending, requester: sixth_user, accepter: user) }

        it "returns all pending friendships where user is involved" do
          result = described_class.call(params: params, current_user: user)
          friendships = result.model

          expect(friendships).to contain_exactly(
            pending_friendship1,
            pending_friendship2,
            friendship3,
            friendship4
          )
        end
      end
    end

    context "when user is not authorized" do
      let(:unauthorized_user) { nil }

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: unauthorized_user)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when policy denies access" do
      before do
        allow_any_instance_of(FriendshipPolicy).to receive(:index?).and_return(false)
      end

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: user)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
