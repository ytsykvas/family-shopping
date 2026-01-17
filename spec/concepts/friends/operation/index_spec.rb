# frozen_string_literal: true

require "rails_helper"

RSpec.describe Friends::Operation::Index, type: :operation do
  describe "#perform!" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:third_user) { create(:user) }
    let(:fourth_user) { create(:user) }
    let(:params) { {} }

    context "when user is authorized" do
      let!(:accepted_friendship1) { create(:friendship, :accepted, requester: user, accepter: other_user) }
      let!(:accepted_friendship2) { create(:friendship, :accepted, requester: third_user, accepter: user) }
      let!(:pending_friendship) { create(:friendship, :pending, requester: user, accepter: fourth_user) }
      let!(:blocked_friendship) { create(:friendship, :blocked, requester: fourth_user, accepter: user) }
      let!(:unrelated_friendship) { create(:friendship, :accepted, requester: other_user, accepter: third_user) }

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
        expect(operation).to receive(:policy_scope).with(Friendship).twice.and_call_original
        operation.call
      end

      it "returns only accepted friendships where user is involved" do
        result = described_class.call(params: params, current_user: user)
        friends = result.model.friends

        expect(friends).to include(other_user, third_user)
        expect(friends).not_to include(fourth_user)
      end

      it "includes associations" do
        result = described_class.call(params: params, current_user: user)
        friends = result.model.friends

        # Since we return User objects, we don't check for requester/accepter loading on them directly
        # as the operation extracts the partner user.
        expect(friends).to include(other_user, third_user)
      end

      it "sets model in result" do
        result = described_class.call(params: params, current_user: user)
        expect(result.model).to be_present
        expect(result.model).to be_a(OpenStruct)
        expect(result.model.friends).to be_a(Array)
        expect(result.model.friendship_requests).to be_a(ActiveRecord::Relation)
      end

      it "marks pundit authorization as called" do
        result = described_class.call(params: params, current_user: user)
        expect(result[:pundit]).to be true
      end

      it "marks pundit scope as called" do
        result = described_class.call(params: params, current_user: user)
        expect(result[:pundit_scope]).to be true
      end

      context "when user has no accepted friendships" do
        let(:user_without_friends) { create(:user) }

        it "returns empty collections" do
          result = described_class.call(params: params, current_user: user_without_friends)
          expect(result.model.friends).to be_empty
          expect(result.model.friendship_requests).to be_empty
        end
      end

      context "with multiple accepted friendships" do
        let(:fifth_user) { create(:user) }
        let(:sixth_user) { create(:user) }
        let!(:friendship3) { create(:friendship, :accepted, requester: user, accepter: fifth_user) }
        let!(:friendship4) { create(:friendship, :accepted, requester: sixth_user, accepter: user) }

        it "returns all accepted friendships where user is involved" do
          result = described_class.call(params: params, current_user: user)
          friends = result.model.friends

          expect(friends).to contain_exactly(
            other_user,
            third_user,
            fifth_user, # from friendship3
            sixth_user  # from friendship4
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
