# frozen_string_literal: true

require "rails_helper"

RSpec.describe FriendshipRequest::Operation::Destroy, type: :operation do
  describe "#perform!" do
    let(:requester) { create(:user) }
    let(:accepter) { create(:user) }
    let!(:friendship) { create(:friendship, :pending, requester: requester, accepter: accepter) }
    let(:params) { { id: friendship.id } }

    context "when requester cancels the request" do
      it "returns successful result" do
        result = described_class.call(params: params, current_user: requester)
        expect(result).to be_success
      end

      it "destroys the friendship" do
        expect do
          described_class.call(params: params, current_user: requester)
        end.to change(Friendship, :count).by(-1)
      end

      it "calls authorize! with friendship and :destroy?" do
        operation = described_class.new(params: params, current_user: requester)
        expect(operation).to receive(:authorize!).with(friendship, :destroy?)
        operation.call
      end

      it "sets model in result" do
        result = described_class.call(params: params, current_user: requester)
        expect(result.model).to eq(friendship)
      end

      it "sets redirect_path to /friends" do
        result = described_class.call(params: params, current_user: requester)
        expect(result.redirect_path).to eq("/friends")
      end

      it "sets success notice" do
        result = described_class.call(params: params, current_user: requester)
        expect(result.message).to eq(I18n.t("friendship_requests.destroy.success"))
      end

      it "marks pundit authorization as called" do
        result = described_class.call(params: params, current_user: requester)
        expect(result[:pundit]).to be true
      end
    end

    context "when accepter rejects the request" do
      it "returns successful result" do
        result = described_class.call(params: params, current_user: accepter)
        expect(result).to be_success
      end

      it "destroys the friendship" do
        expect do
          described_class.call(params: params, current_user: accepter)
        end.to change(Friendship, :count).by(-1)
      end

      it "sets success notice" do
        result = described_class.call(params: params, current_user: accepter)
        expect(result.message).to eq(I18n.t("friendship_requests.destroy.success"))
      end
    end

    context "when user is neither requester nor accepter" do
      let(:other_user) { create(:user) }

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: other_user)
        end.to raise_error(Pundit::NotAuthorizedError)
      end

      it "does not destroy the friendship" do
        expect do
          begin
            described_class.call(params: params, current_user: other_user)
          rescue Pundit::NotAuthorizedError
            # Expected error
          end
        end.not_to change(Friendship, :count)
      end
    end

    context "when friendship is not pending" do
      let!(:friendship) { create(:friendship, :accepted, requester: requester, accepter: accepter) }

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: requester)
        end.to raise_error(Pundit::NotAuthorizedError)
      end

      it "does not destroy the friendship" do
        expect do
          begin
            described_class.call(params: params, current_user: requester)
          rescue Pundit::NotAuthorizedError
            # Expected error
          end
        end.not_to change(Friendship, :count)
      end
    end

    context "when friendship is blocked" do
      let!(:friendship) { create(:friendship, :blocked, requester: requester, accepter: accepter) }

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: requester)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when user is not authorized" do
      before do
        allow_any_instance_of(FriendshipPolicy).to receive(:destroy?).and_return(false)
      end

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: requester)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when friendship does not exist" do
      let(:params) { { id: 99999 } }

      it "raises ActiveRecord::RecordNotFound" do
        expect do
          described_class.call(params: params, current_user: requester)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
