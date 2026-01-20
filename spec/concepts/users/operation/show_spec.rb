# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::Operation::Show do
  subject(:result) { described_class.call(params: params, current_user: current_user) }

  let(:current_user) { create(:user) }
  let(:target_user) { create(:user) }
  let(:params) { { id: target_user.id } }

  describe "#perform!" do
    context "when viewing another user's profile" do
      it "returns success" do
        expect(result).to be_success
      end

      it "returns the target user" do
        expect(result.model.user).to eq(target_user)
      end

      context "when they are friends" do
        before do
          create(:friendship, :accepted, requester: current_user, accepter: target_user)
        end

        it "marks is_friend as true" do
          expect(result.model.is_friend).to be true
        end
      end

      context "when there is an incoming request" do
        let!(:request) { create(:friendship, :pending, requester: target_user, accepter: current_user) }

        it "includes the incoming request" do
          expect(result.model.incoming_request).to eq(request)
          expect(result.model.is_friend).to be_falsey
        end
      end

      context "when there is an outgoing request" do
        let!(:request) { create(:friendship, :pending, requester: current_user, accepter: target_user) }

        it "includes the outgoing request" do
          expect(result.model.outgoing_request).to eq(request)
          expect(result.model.is_friend).to be_falsey
        end
      end
    end

    context "when viewing own profile" do
      let(:params) { { id: current_user.id } }

      it "returns success" do
        expect(result).to be_success
      end

      it "returns current user as the user" do
        expect(result.model.user).to eq(current_user)
      end
    end

    context "when user does not exist" do
      let(:params) { { id: 999_999 } }

      it "raises ActiveRecord::RecordNotFound" do
        expect { result }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when user is not authenticated" do
      let(:current_user) { nil }

      it "raises Pundit::NotAuthorizedError" do
        expect { result }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
