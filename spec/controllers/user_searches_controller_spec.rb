# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserSearchesController, type: :controller do
  describe "GET #index" do
    let(:user) { create(:user) }

    context "when user is authenticated" do
      before do
        sign_in user
      end

      context "with turbo_stream format" do
        let(:params) { { query: "test" } }

        it "calls endpoint_partial with correct operation and component" do
          expect(controller).to receive(:endpoint_partial).with(
            UserSearches::Operation::Index,
            UserSearches::Component::Results,
            target_id: "user-search-results"
          ).and_call_original
          get :index, params: params, format: :turbo_stream
        end

        it "returns successful response" do
          get :index, params: params, format: :turbo_stream
          expect(response).to have_http_status(:success)
        end

        it "renders turbo_stream format" do
          get :index, params: params, format: :turbo_stream
          expect(response.content_type).to include("text/vnd.turbo-stream.html")
        end
      end

      context "with html format" do
        let(:params) { { query: "test" } }

        it "calls endpoint_partial with correct operation and component" do
          expect(controller).to receive(:endpoint_partial).with(
            UserSearches::Operation::Index,
            UserSearches::Component::Results,
            target_id: "user-search-results"
          ).and_call_original
          get :index, params: params, format: :html
        end
      end

      context "with empty query" do
        let(:params) { { query: "" } }

        it "returns successful response" do
          get :index, params: params, format: :turbo_stream
          expect(response).to have_http_status(:success)
        end
      end

      context "with no query parameter" do
        let(:params) { {} }

        it "returns successful response" do
          get :index, params: params, format: :turbo_stream
          expect(response).to have_http_status(:success)
        end
      end

      context "with matching users" do
        let!(:matching_user) { create(:user, nickname: "test_user", email: "test@example.com") }
        let(:params) { { query: "test" } }

        it "returns successful response" do
          get :index, params: params, format: :turbo_stream
          expect(response).to have_http_status(:success)
        end
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get :index, params: { query: "test" }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not call endpoint_partial" do
        expect(controller).not_to receive(:endpoint_partial)
        get :index, params: { query: "test" }
      end
    end
  end
end
