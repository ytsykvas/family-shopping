require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let!(:user) { create(:user, password: "password", email: "test@example.com", nickname: "tester") }

  describe "POST /api/v1/sessions/login" do
    it "returns token for valid email" do
      post "/api/v1/sessions/login", params: { email: user.email, password: "password" }

      expect(response).to have_http_status(:created)
      expect(json["token"]).to be_present
      expect(json["user_id"]).to eq(user.id)
    end

    it "returns token for valid nickname" do
      post "/api/v1/sessions/login", params: { nickname: user.nickname, password: "password" }

      expect(response).to have_http_status(:created)
      expect(json["token"]).to be_present
      expect(json["user_id"]).to eq(user.id)
    end

    it "returns token when both email and nickname provided" do
      post "/api/v1/sessions/login", params: { email: user.email, nickname: user.nickname, password: "password" }

      expect(response).to have_http_status(:created)
    end

    it "returns 400 when neither email nor nickname provided" do
      post "/api/v1/sessions/login", params: { password: "password" }

      expect(response).to have_http_status(:bad_request) # Grape validation error
    end

    it "returns 401 for invalid credentials" do
      post "/api/v1/sessions/login", params: { email: user.email, password: "wrong_password" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
