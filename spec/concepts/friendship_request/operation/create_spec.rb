# frozen_string_literal: true

require "rails_helper"

RSpec.describe FriendshipRequest::Operation::Create, type: :operation do
  describe "#perform!" do
    let(:user) { create(:user) }
    let(:accepter) { create(:user) }
    let(:params) do
      {
        friendship_request: {
          accepter_id: accepter.id
        }
      }
    end

    context "when user is authorized" do
      it "returns successful result" do
        result = described_class.call(params: params, current_user: user)
        expect(result).to be_success
      end

      it "creates a new friendship with pending status" do
        expect do
          described_class.call(params: params, current_user: user)
        end.to change(Friendship, :count).by(1)

        friendship = Friendship.last
        expect(friendship.requester).to eq(user)
        expect(friendship.accepter).to eq(accepter)
        expect(friendship.status).to eq("pending")
      end

      it "calls authorize! with friendship and :create?" do
        operation = described_class.new(params: params, current_user: user)
        expect(operation).to receive(:authorize!).with(an_instance_of(Friendship), :create?)
        operation.call
      end

      it "sets model in result" do
        result = described_class.call(params: params, current_user: user)
        expect(result.model).to be_a(Friendship)
        expect(result.model.requester).to eq(user)
        expect(result.model.accepter).to eq(accepter)
      end

      it "sets redirect_path to /friends" do
        result = described_class.call(params: params, current_user: user)
        expect(result.redirect_path).to eq("/friends")
      end

      it "sets success notice" do
        result = described_class.call(params: params, current_user: user)
        expect(result.message).to eq(I18n.t("friendship_requests.create.success"))
      end

      it "marks pundit authorization as called" do
        result = described_class.call(params: params, current_user: user)
        expect(result[:pundit]).to be true
      end

      context "when user tries to request friendship with themselves" do
        let(:params) do
          {
            friendship_request: {
              accepter_id: user.id
            }
          }
        end

        it "returns failure result" do
          result = described_class.call(params: params, current_user: user)
          expect(result).to be_failure
        end

        it "does not create friendship" do
          expect do
            described_class.call(params: params, current_user: user)
          end.not_to change(Friendship, :count)
        end

        it "adds error message" do
          result = described_class.call(params: params, current_user: user)
          expect(result.error_message).to include(I18n.t("friendship_requests.create.cannot_request_self"))
        end

        it "sets redirect_path to /friends" do
          result = described_class.call(params: params, current_user: user)
          expect(result.redirect_path).to eq("/friends")
        end
      end

      context "when friendship already exists" do
        let!(:existing_friendship) { create(:friendship, :pending, requester: user, accepter: accepter) }

        it "returns failure result" do
          result = described_class.call(params: params, current_user: user)
          expect(result).to be_failure
        end

        it "does not create new friendship" do
          expect do
            described_class.call(params: params, current_user: user)
          end.not_to change(Friendship, :count)
        end

        it "adds error message" do
          result = described_class.call(params: params, current_user: user)
          expect(result.error_message).to include(I18n.t("friendship_requests.create.already_exists"))
        end

        it "sets redirect_path to /friends" do
          result = described_class.call(params: params, current_user: user)
          expect(result.redirect_path).to eq("/friends")
        end
      end

      context "when reverse friendship already exists" do
        let!(:existing_friendship) { create(:friendship, :pending, requester: accepter, accepter: user) }

        it "returns failure result" do
          result = described_class.call(params: params, current_user: user)
          expect(result).to be_failure
        end

        it "does not create new friendship" do
          expect do
            described_class.call(params: params, current_user: user)
          end.not_to change(Friendship, :count)
        end
      end

      context "when accepted friendship already exists" do
        let!(:existing_friendship) { create(:friendship, :accepted, requester: user, accepter: accepter) }

        it "returns failure result" do
          result = described_class.call(params: params, current_user: user)
          expect(result).to be_failure
        end

        it "does not create new friendship" do
          expect do
            described_class.call(params: params, current_user: user)
          end.not_to change(Friendship, :count)
        end
      end

      context "with message parameter" do
        let(:params) do
          {
            friendship_request: {
              accepter_id: accepter.id,
              message: "Let's be friends!"
            }
          }
        end

        it "creates friendship with message" do
          result = described_class.call(params: params, current_user: user)
          expect(result.model.message).to eq("Let's be friends!")
        end
      end
    end

    context "when user is not authorized" do
      before do
        allow_any_instance_of(FriendshipPolicy).to receive(:create?).and_return(false)
      end

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: user)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
