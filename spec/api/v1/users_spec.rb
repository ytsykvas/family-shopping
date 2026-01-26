require 'rails_helper'

RSpec.describe V1::Users, type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v1/users/:id" do
    it "returns the user details" do
      get "/api/v1/users/#{user.id}", headers: headers
      expect(response).to have_http_status(:success)
      expect(json["id"]).to eq(user.id)
      expect(json["email"]).to eq(user.email)
    end

    it "returns 404 for non-existent user" do
      get "/api/v1/users/0", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/users/check_nickname" do
    it "returns true if nickname is available" do
      get "/api/v1/users/check_nickname", params: { nickname: "new_nick" }
      expect(response).to have_http_status(:success)
      expect(json["available"]).to be true
    end

    it "returns false if nickname is taken" do
      create(:user, nickname: "taken_nick")
      get "/api/v1/users/check_nickname", params: { nickname: "taken_nick" }
      expect(response).to have_http_status(:success)
      expect(json["available"]).to be false
    end
  end

  describe "GET /api/v1/users/check_email" do
    it "returns true if email is available" do
      get "/api/v1/users/check_email", params: { email: "new@example.com" }
      expect(response).to have_http_status(:success)
      expect(json["available"]).to be true
    end

    it "returns false if email is taken" do
      create(:user, email: "taken@example.com")
      get "/api/v1/users/check_email", params: { email: "taken@example.com" }
      expect(response).to have_http_status(:success)
      expect(json["available"]).to be false
    end
  end
end
