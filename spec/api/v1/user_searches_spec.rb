require "rails_helper"

RSpec.describe "UserSearches", type: :request do
  let(:user) { create(:user) }
  let!(:other_user) { create(:user, nickname: "target_user") }
  let(:headers) { authenticated_header(user) }

  describe "GET /api/v1/user_searches" do
    it "returns matching users" do
      get "/api/v1/user_searches", params: { query: "target" }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json.count).to eq(1)
      expect(json.first["nickname"]).to eq("target_user")
    end
  end
end
