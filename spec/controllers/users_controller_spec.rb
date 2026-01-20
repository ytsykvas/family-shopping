# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:target_user) { create(:user) }

  describe "GET #show" do
    context "when user is authenticated" do
      before { sign_in user }

      it "calls endpoint with correct operation and component" do
        expect(controller).to receive(:endpoint).with(
          Users::Operation::Show,
          Users::Component::Show
        ).and_call_original

        get :show, params: { id: target_user.id }
      end

      it "returns successful response" do
        get :show, params: { id: target_user.id }
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get :show, params: { id: target_user.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when verify_policy_scoped is called" do
      before { sign_in user }

      it "does not raise ActionNotFound because it is skipped" do
        # This tests that our skip_after_action :verify_policy_scoped works
        expect { get :show, params: { id: target_user.id } }.not_to raise_error
      end
    end
  end
end
