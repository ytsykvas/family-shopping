# frozen_string_literal: true

require "rails_helper"

RSpec.describe FriendshipRequest::Operation::Update, type: :operation do
  describe "#perform!" do
    let(:requester) { create(:user) }
    let(:accepter) { create(:user) }
    let!(:friendship) { create(:friendship, :pending, requester: requester, accepter: accepter) }
    let(:params) { { id: friendship.id } }

    context "when accepter accepts the request" do
      it "returns successful result" do
        result = described_class.call(params: params, current_user: accepter)
        expect(result).to be_success
      end

      it "updates friendship status to accepted" do
        described_class.call(params: params, current_user: accepter)
        friendship.reload
        expect(friendship.status).to eq("accepted")
      end

      it "calls authorize! with friendship and :update?" do
        operation = described_class.new(params: params, current_user: accepter)
        expect(operation).to receive(:authorize!).with(friendship, :update?)
        operation.call
      end

      it "sets model in result" do
        result = described_class.call(params: params, current_user: accepter)
        expect(result.model).to eq(friendship)
        expect(result.model.status).to eq("accepted")
      end

      it "sets redirect_path to /friends" do
        result = described_class.call(params: params, current_user: accepter)
        expect(result.redirect_path).to eq("/friends")
      end

      it "sets success notice" do
        result = described_class.call(params: params, current_user: accepter)
        expect(result.message).to eq(I18n.t("friendship_requests.update.success"))
      end

      it "marks pundit authorization as called" do
        result = described_class.call(params: params, current_user: accepter)
        expect(result[:pundit]).to be true
      end
    end

    context "when requester tries to accept their own request" do
      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: requester)
        end.to raise_error(Pundit::NotAuthorizedError)
      end

      it "does not update friendship status" do
        begin
          described_class.call(params: params, current_user: requester)
        rescue Pundit::NotAuthorizedError
          # Expected error
        end
        friendship.reload
        expect(friendship.status).to eq("pending")
      end
    end

    context "when friendship is not pending" do
      let!(:friendship) { create(:friendship, :accepted, requester: requester, accepter: accepter) }

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: accepter)
        end.to raise_error(Pundit::NotAuthorizedError)
      end

      it "does not change friendship status" do
        old_status = friendship.status
        begin
          described_class.call(params: params, current_user: accepter)
        rescue Pundit::NotAuthorizedError
          # Expected error
        end
        friendship.reload
        expect(friendship.status).to eq(old_status)
      end
    end

    context "when friendship is blocked" do
      let!(:friendship) { create(:friendship, :blocked, requester: requester, accepter: accepter) }

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: accepter)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when user is not authorized" do
      before do
        allow_any_instance_of(FriendshipPolicy).to receive(:update?).and_return(false)
      end

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: accepter)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when friendship does not exist" do
      let(:params) { { id: 99999 } }

      it "raises ActiveRecord::RecordNotFound" do
        expect do
          described_class.call(params: params, current_user: accepter)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
