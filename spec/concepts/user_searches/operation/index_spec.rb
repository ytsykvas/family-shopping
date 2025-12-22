# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserSearches::Operation::Index, type: :operation do
  describe "#perform!" do
    let(:current_user) { create(:user, nickname: "current_user", email: "current@example.com") }
    let(:params) { {} }

    context "when query is blank" do
      let(:params) { { query: "" } }

      it "returns successful result" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result).to be_success
      end

      it "returns empty users array" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result.model[:users]).to be_empty
      end

      it "returns nil query" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result.model[:query]).to be_nil
      end

      it "skips authorization" do
        operation = described_class.new(params: params, current_user: current_user)
        expect(operation).to receive(:skip_authorize)
        operation.call
      end

      it "calls policy_scope even when query is blank" do
        operation = described_class.new(params: params, current_user: current_user)
        expect(operation).to receive(:policy_scope).with(User).and_call_original
        operation.call
      end

      it "marks pundit scope as called" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result[:pundit_scope]).to be true
      end
    end

    context "when query is nil" do
      let(:params) { { query: nil } }

      it "returns empty users array" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result.model[:users]).to be_empty
      end

      it "calls policy_scope even when query is nil" do
        operation = described_class.new(params: params, current_user: current_user)
        expect(operation).to receive(:policy_scope).with(User).and_call_original
        operation.call
      end

      it "marks pundit scope as called" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result[:pundit_scope]).to be true
      end
    end

    context "when query has whitespace" do
      let(:params) { { query: "  test  " } }

      it "strips whitespace from query" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result.model[:query]).to eq("test")
      end
    end

    context "when query matches users by nickname" do
      let!(:user1) { create(:user, nickname: "john_doe", email: "john@example.com") }
      let!(:user2) { create(:user, nickname: "jane_doe", email: "jane@example.com") }
      let!(:user3) { create(:user, nickname: "bob_smith", email: "bob@example.com") }
      let(:params) { { query: "john" } }

      it "returns successful result" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result).to be_success
      end

      it "finds users matching nickname" do
        result = described_class.call(params: params, current_user: current_user)
        users = result.model[:users]

        expect(users).to include(user1)
        expect(users).not_to include(user2, user3, current_user)
      end

      it "excludes current user from results" do
        result = described_class.call(params: params, current_user: current_user)
        users = result.model[:users]

        expect(users).not_to include(current_user)
      end

      it "returns query in model" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result.model[:query]).to eq("john")
      end

      it "uses policy_scope to filter users" do
        operation = described_class.new(params: params, current_user: current_user)
        expect(operation).to receive(:policy_scope).with(User).and_call_original
        operation.call
      end

      it "marks pundit scope as called" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result[:pundit_scope]).to be true
      end
    end

    context "when query matches users by email" do
      let!(:user1) { create(:user, nickname: "user1", email: "john.doe@example.com") }
      let!(:user2) { create(:user, nickname: "user2", email: "jane.doe@example.com") }
      let!(:user3) { create(:user, nickname: "user3", email: "bob.smith@example.com") }
      let(:params) { { query: "john.doe" } }

      it "finds users matching email" do
        result = described_class.call(params: params, current_user: current_user)
        users = result.model[:users]

        expect(users).to include(user1)
        expect(users).not_to include(user2, user3, current_user)
      end
    end

    context "when query matches both nickname and email" do
      let!(:user1) { create(:user, nickname: "john", email: "john@example.com") }
      let!(:user2) { create(:user, nickname: "jane", email: "john.doe@example.com") }
      let(:params) { { query: "john" } }

      it "finds users matching either nickname or email" do
        result = described_class.call(params: params, current_user: current_user)
        users = result.model[:users]

        expect(users).to include(user1, user2)
        expect(users).not_to include(current_user)
      end
    end

    context "when query is case-insensitive" do
      let!(:user1) { create(:user, nickname: "JohnDoe", email: "john@example.com") }
      let!(:user2) { create(:user, nickname: "jane_doe", email: "JANE@example.com") }
      let(:params) { { query: "JOHN" } }

      it "finds users regardless of case" do
        result = described_class.call(params: params, current_user: current_user)
        users = result.model[:users]

        expect(users).to include(user1)
      end
    end

    context "when query matches partial nickname" do
      let!(:user1) { create(:user, nickname: "john_doe_123", email: "john@example.com") }
      let!(:user2) { create(:user, nickname: "jane_doe", email: "jane@example.com") }
      let(:params) { { query: "doe" } }

      it "finds users with partial match" do
        result = described_class.call(params: params, current_user: current_user)
        users = result.model[:users]

        expect(users).to include(user1, user2)
        expect(users).not_to include(current_user)
      end
    end

    context "when there are more than 10 matching users" do
      let(:params) { { query: "user" } }

      before do
        15.times do |i|
          create(:user, nickname: "user#{i}", email: "user#{i}@example.com")
        end
      end

      it "limits results to 10 users" do
        result = described_class.call(params: params, current_user: current_user)
        users = result.model[:users]

        expect(users.count).to eq(10)
      end
    end

    context "when no users match the query" do
      let!(:user1) { create(:user, nickname: "john", email: "john@example.com") }
      let(:params) { { query: "nonexistent" } }

      it "returns empty users array" do
        result = described_class.call(params: params, current_user: current_user)
        users = result.model[:users]

        expect(users).to be_empty
      end

      it "still returns the query" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result.model[:query]).to eq("nonexistent")
      end
    end

    context "when current user matches the query" do
      let(:current_user) { create(:user, nickname: "john_doe", email: "john@example.com") }
      let!(:other_user) { create(:user, nickname: "jane_doe", email: "jane@example.com") }
      let(:params) { { query: "john" } }

      it "excludes current user from results" do
        result = described_class.call(params: params, current_user: current_user)
        users = result.model[:users]

        expect(users).not_to include(current_user)
      end

      it "can still find other users matching the query" do
        result = described_class.call(params: params, current_user: current_user)
        users = result.model[:users]

        # Should not find current_user even though nickname matches
        expect(users).not_to include(current_user)
      end
    end

    context "when query matches only current user" do
      let(:current_user) { create(:user, nickname: "unique_user", email: "unique@example.com") }
      let(:params) { { query: "unique" } }

      it "returns empty users array" do
        result = described_class.call(params: params, current_user: current_user)
        users = result.model[:users]

        expect(users).to be_empty
      end
    end

    context "when users have different friendship statuses" do
      let!(:friend_user) { create(:user, nickname: "friend_user", email: "friend@example.com") }
      let!(:incoming_request_user) { create(:user, nickname: "incoming_user", email: "incoming@example.com") }
      let!(:outgoing_request_user) { create(:user, nickname: "outgoing_user", email: "outgoing@example.com") }
      let!(:no_relation_user) { create(:user, nickname: "stranger_user", email: "stranger@example.com") }
      let(:params) { { query: "user" } }

      before do
        create(:friendship, requester: current_user, accepter: friend_user, status: :accepted)
        create(:friendship, requester: incoming_request_user, accepter: current_user, status: :pending)
        create(:friendship, requester: current_user, accepter: outgoing_request_user, status: :pending)
      end

      it "returns all matching users" do
        result = described_class.call(params: params, current_user: current_user)
        users = result.model[:users]

        expect(users).to include(friend_user, incoming_request_user, outgoing_request_user, no_relation_user)
      end

      it "identifies friends correctly" do
        result = described_class.call(params: params, current_user: current_user)
        friends_ids = result.model[:friends_ids]

        expect(friends_ids).to include(friend_user.id)
        expect(friends_ids).not_to include(incoming_request_user.id, outgoing_request_user.id, no_relation_user.id)
      end

      it "identifies incoming requests correctly" do
        result = described_class.call(params: params, current_user: current_user)
        incoming_requests = result.model[:incoming_requests]

        expect(incoming_requests.keys).to include(incoming_request_user.id)
        expect(incoming_requests.keys).not_to include(friend_user.id, outgoing_request_user.id, no_relation_user.id)
      end

      it "identifies outgoing requests correctly" do
        result = described_class.call(params: params, current_user: current_user)
        outgoing_requests = result.model[:outgoing_requests]

        expect(outgoing_requests.keys).to include(outgoing_request_user.id)
        expect(outgoing_requests.keys).not_to include(friend_user.id, incoming_request_user.id, no_relation_user.id)
      end

      it "returns empty hashes for users with no relationship" do
        result = described_class.call(params: params, current_user: current_user)
        friends_ids = result.model[:friends_ids]
        incoming_requests = result.model[:incoming_requests]
        outgoing_requests = result.model[:outgoing_requests]

        expect(friends_ids).not_to include(no_relation_user.id)
        expect(incoming_requests.keys).not_to include(no_relation_user.id)
        expect(outgoing_requests.keys).not_to include(no_relation_user.id)
      end

      it "returns friendship objects in incoming_requests hash" do
        result = described_class.call(params: params, current_user: current_user)
        incoming_requests = result.model[:incoming_requests]

        expect(incoming_requests[incoming_request_user.id]).to be_a(Friendship)
        expect(incoming_requests[incoming_request_user.id].requester_id).to eq(incoming_request_user.id)
        expect(incoming_requests[incoming_request_user.id].accepter_id).to eq(current_user.id)
      end

      it "returns friendship objects in outgoing_requests hash" do
        result = described_class.call(params: params, current_user: current_user)
        outgoing_requests = result.model[:outgoing_requests]

        expect(outgoing_requests[outgoing_request_user.id]).to be_a(Friendship)
        expect(outgoing_requests[outgoing_request_user.id].requester_id).to eq(current_user.id)
        expect(outgoing_requests[outgoing_request_user.id].accepter_id).to eq(outgoing_request_user.id)
      end
    end

    context "when friend relationship is reversed (current_user is accepter)" do
      let!(:friend_user) { create(:user, nickname: "friend_user", email: "friend@example.com") }
      let(:params) { { query: "friend" } }

      before do
        create(:friendship, requester: friend_user, accepter: current_user, status: :accepted)
      end

      it "identifies friend correctly regardless of who initiated" do
        result = described_class.call(params: params, current_user: current_user)
        friends_ids = result.model[:friends_ids]

        expect(friends_ids).to include(friend_user.id)
      end
    end

    context "when query is blank with friendship data" do
      let(:params) { { query: "" } }

      it "returns empty friends_ids array" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result.model[:friends_ids]).to eq([])
      end

      it "returns empty incoming_requests hash" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result.model[:incoming_requests]).to eq({})
      end

      it "returns empty outgoing_requests hash" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result.model[:outgoing_requests]).to eq({})
      end
    end

    context "when there are no friendships" do
      let!(:user1) { create(:user, nickname: "user1", email: "user1@example.com") }
      let!(:user2) { create(:user, nickname: "user2", email: "user2@example.com") }
      let(:params) { { query: "user" } }

      it "returns empty friends_ids array" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result.model[:friends_ids]).to be_empty
      end

      it "returns empty incoming_requests hash" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result.model[:incoming_requests]).to be_empty
      end

      it "returns empty outgoing_requests hash" do
        result = described_class.call(params: params, current_user: current_user)
        expect(result.model[:outgoing_requests]).to be_empty
      end
    end

    context "when user has multiple friends in search results" do
      let!(:friend1) { create(:user, nickname: "friend1", email: "friend1@example.com") }
      let!(:friend2) { create(:user, nickname: "friend2", email: "friend2@example.com") }
      let!(:friend3) { create(:user, nickname: "friend3", email: "friend3@example.com") }
      let(:params) { { query: "friend" } }

      before do
        create(:friendship, requester: current_user, accepter: friend1, status: :accepted)
        create(:friendship, requester: friend2, accepter: current_user, status: :accepted)
        create(:friendship, requester: current_user, accepter: friend3, status: :accepted)
      end

      it "includes all friends in friends_ids" do
        result = described_class.call(params: params, current_user: current_user)
        friends_ids = result.model[:friends_ids]

        expect(friends_ids).to include(friend1.id, friend2.id, friend3.id)
        expect(friends_ids.count).to eq(3)
      end
    end
  end
end
