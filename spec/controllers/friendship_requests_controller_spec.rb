# frozen_string_literal: true

require "rails_helper"

RSpec.describe FriendshipRequestsController, type: :controller do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "GET #index" do
    context "when user is authenticated" do
      before do
        sign_in user
      end

      it "calls endpoint with correct operation and component" do
        expect(controller).to receive(:endpoint).with(
          FriendshipRequest::Operation::Index,
          FriendshipRequest::Component::Index
        ).and_call_original
        get :index
      end

      it "returns successful response" do
        get :index
        expect(response).to have_http_status(:success)
      end

      context "with pending friendship requests" do
        let!(:pending_request) { create(:friendship, :pending, requester: other_user, accepter: user) }

        it "returns successful response" do
          get :index
          expect(response).to have_http_status(:success)
        end
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not call endpoint" do
        expect(controller).not_to receive(:endpoint)
        get :index
      end
    end
  end

  describe "POST #create" do
    let(:params) do
      {
        friendship_request: {
          accepter_id: other_user.id
        }
      }
    end

    context "when user is authenticated" do
      before do
        sign_in user
      end

      it "calls endpoint with correct operation" do
        expect(controller).to receive(:endpoint).with(
          FriendshipRequest::Operation::Create
        ).and_call_original
        post :create, params: params
      end

      it "creates a new friendship request" do
        expect do
          post :create, params: params
        end.to change(Friendship, :count).by(1)
      end

      it "redirects to friends page" do
        post :create, params: params
        expect(response).to redirect_to("/friends")
      end

      it "sets success notice" do
        post :create, params: params
        expect(flash[:notice]).to eq(I18n.t("friendship_requests.create.success"))
      end

      context "when trying to send request to self" do
        let(:params) do
          {
            friendship_request: {
              accepter_id: user.id
            }
          }
        end

        it "does not create friendship" do
          expect do
            post :create, params: params
          end.not_to change(Friendship, :count)
        end

        it "redirects to friends page" do
          post :create, params: params
          expect(response).to redirect_to("/friends")
        end

        it "sets error alert" do
          post :create, params: params
          expect(flash[:alert]).to include(I18n.t("friendship_requests.create.cannot_request_self"))
        end
      end

      context "when friendship already exists" do
        let!(:existing_friendship) { create(:friendship, :pending, requester: user, accepter: other_user) }

        it "does not create new friendship" do
          expect do
            post :create, params: params
          end.not_to change(Friendship, :count)
        end

        it "sets error alert" do
          post :create, params: params
          expect(flash[:alert]).to include(I18n.t("friendship_requests.create.already_exists"))
        end
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        post :create, params: params
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not create friendship" do
        expect do
          post :create, params: params
        end.not_to change(Friendship, :count)
      end
    end
  end

  describe "PATCH #update" do
    let!(:friendship) { create(:friendship, :pending, requester: other_user, accepter: user) }
    let(:params) { { id: friendship.id } }

    context "when user is authenticated as accepter" do
      before do
        sign_in user
      end

      it "calls endpoint with correct operation" do
        expect(controller).to receive(:endpoint).with(
          FriendshipRequest::Operation::Update
        ).and_call_original
        patch :update, params: params
      end

      it "updates friendship status to accepted" do
        patch :update, params: params
        friendship.reload
        expect(friendship.status).to eq("accepted")
      end

      it "redirects to friends page" do
        patch :update, params: params
        expect(response).to redirect_to("/friends")
      end

      it "sets success notice" do
        patch :update, params: params
        expect(flash[:notice]).to eq(I18n.t("friendship_requests.update.success"))
      end

      context "when friendship is already accepted" do
        let!(:friendship) { create(:friendship, :accepted, requester: other_user, accepter: user) }

        it "redirects with error" do
          patch :update, params: params
          expect(response).to have_http_status(:redirect)
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "when user is authenticated as requester" do
      before do
        sign_in other_user
      end

      it "redirects with error" do
        patch :update, params: params
        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).to be_present
      end

      it "does not update friendship status" do
        patch :update, params: params
        friendship.reload
        expect(friendship.status).to eq("pending")
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        patch :update, params: params
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not update friendship" do
        patch :update, params: params
        friendship.reload
        expect(friendship.status).to eq("pending")
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:friendship) { create(:friendship, :pending, requester: user, accepter: other_user) }
    let(:params) { { id: friendship.id } }

    context "when user is authenticated as requester" do
      before do
        sign_in user
      end

      it "calls endpoint with correct operation" do
        expect(controller).to receive(:endpoint).with(
          FriendshipRequest::Operation::Destroy
        ).and_call_original
        delete :destroy, params: params
      end

      it "destroys the friendship" do
        expect do
          delete :destroy, params: params
        end.to change(Friendship, :count).by(-1)
      end

      it "redirects to friends page" do
        delete :destroy, params: params
        expect(response).to redirect_to("/friends")
      end

      it "sets success notice" do
        delete :destroy, params: params
        expect(flash[:notice]).to eq(I18n.t("friendship_requests.destroy.success"))
      end
    end

    context "when user is authenticated as accepter" do
      before do
        sign_in other_user
      end

      it "destroys the friendship" do
        expect do
          delete :destroy, params: params
        end.to change(Friendship, :count).by(-1)
      end

      it "redirects to friends page" do
        delete :destroy, params: params
        expect(response).to redirect_to("/friends")
      end

      it "sets success notice" do
        delete :destroy, params: params
        expect(flash[:notice]).to eq(I18n.t("friendship_requests.destroy.success"))
      end
    end

    context "when user is neither requester nor accepter" do
      let(:third_user) { create(:user) }

      before do
        sign_in third_user
      end

      it "redirects with error" do
        delete :destroy, params: params
        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).to be_present
      end

      it "does not destroy the friendship" do
        expect do
          delete :destroy, params: params
        end.not_to change(Friendship, :count)
      end
    end

    context "when friendship is already accepted" do
      let!(:friendship) { create(:friendship, :accepted, requester: user, accepter: other_user) }

      before do
        sign_in user
      end

      it "redirects with error" do
        delete :destroy, params: params
        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).to be_present
      end

      it "does not destroy the friendship" do
        expect do
          delete :destroy, params: params
        end.not_to change(Friendship, :count)
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        delete :destroy, params: params
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not destroy friendship" do
        expect do
          delete :destroy, params: params
        end.not_to change(Friendship, :count)
      end
    end
  end
end
