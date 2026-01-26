require 'rails_helper'

RSpec.describe "Home", type: :request do
  describe "GET /" do
    it "returns http success for unauthenticated user" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    context "when user is authenticated" do
      let(:user) { create(:user) }
      before { sign_in user }

      it "returns http success" do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
