# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API V1 Users", type: :request do
  describe "GET /api/v1/users/check_nickname" do
    context "when nickname is available" do
      let(:nickname) { Faker::Internet.unique.username(specifier: 5..20) }

      it "returns 200 status" do
        get "/api/v1/users/check_nickname", params: { nickname: nickname }
        expect(response).to have_http_status(:ok)
      end

      it "returns JSON with available true" do
        get "/api/v1/users/check_nickname", params: { nickname: nickname }
        json = JSON.parse(response.body)

        expect(json["available"]).to be true
        expect(json["message"]).to eq(I18n.t("api.users.nickname_available"))
      end

      it "returns proper content type" do
        get "/api/v1/users/check_nickname", params: { nickname: nickname }
        expect(response.content_type).to include("application/json")
      end
    end

    context "when nickname is taken" do
      let!(:existing_user) { create(:user, nickname: "takenuser") }

      it "returns available false" do
        get "/api/v1/users/check_nickname", params: { nickname: "takenuser" }
        json = JSON.parse(response.body)

        expect(json["available"]).to be false
        expect(json["message"]).to eq(I18n.t("api.users.nickname_taken"))
      end
    end

    context "when nickname parameter is missing" do
      it "returns 400 bad request" do
        get "/api/v1/users/check_nickname"
        expect(response).to have_http_status(:bad_request)
      end

      it "returns error message" do
        get "/api/v1/users/check_nickname"
        json = JSON.parse(response.body)

        expect(json["error"]).to eq("nickname is missing")
      end
    end

    context "when accessed without authentication" do
      let(:nickname) { "test" }

      it "allows access (public endpoint)" do
        get "/api/v1/users/check_nickname", params: { nickname: nickname }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /api/v1/users/check_email" do
    context "when email is available and valid" do
      let(:email) { Faker::Internet.unique.email }

      it "returns 200 status" do
        get "/api/v1/users/check_email", params: { email: email }
        expect(response).to have_http_status(:ok)
      end

      it "returns JSON with available true" do
        get "/api/v1/users/check_email", params: { email: email }
        json = JSON.parse(response.body)

        expect(json["available"]).to be true
        expect(json["message"]).to eq(I18n.t("api.users.email_available"))
      end
    end

    context "when email is taken" do
      let!(:existing_user) { create(:user, email: "taken@example.com") }

      it "returns available false" do
        get "/api/v1/users/check_email", params: { email: "taken@example.com" }
        json = JSON.parse(response.body)

        expect(json["available"]).to be false
        expect(json["message"]).to eq(I18n.t("api.users.email_taken"))
      end
    end

    context "when email format is invalid" do
      it "returns available false with invalid message" do
        get "/api/v1/users/check_email", params: { email: "invalid-format" }
        json = JSON.parse(response.body)

        expect(json["available"]).to be false
        expect(json["message"]).to eq(I18n.t("api.users.email_invalid"))
      end
    end

    context "when email parameter is missing" do
      it "returns 400 bad request" do
        get "/api/v1/users/check_email"
        expect(response).to have_http_status(:bad_request)
      end

      it "returns error message" do
        get "/api/v1/users/check_email"
        json = JSON.parse(response.body)

        expect(json["error"]).to eq("email is missing")
      end
    end

    context "when accessed without authentication" do
      let(:email) { "test@example.com" }

      it "allows access (public endpoint)" do
        get "/api/v1/users/check_email", params: { email: email }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
