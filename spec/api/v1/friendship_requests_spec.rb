require "rails_helper"

RSpec.describe "FriendshipRequests", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { authenticated_header(user) }

  describe "GET /api/v1/friendship_requests" do
    let!(:incoming) { create(:friendship, requester: other_user, accepter: user, status: :pending) }

    it "returns friendship requests" do
      get "/api/v1/friendship_requests", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["incoming_requests"].count).to eq(1)
      expect(json["incoming_requests"].first["id"]).to eq(incoming.id)
    end
  end

  describe "POST /api/v1/friendship_requests" do
    it "sends a friendship request" do
      expect {
        post "/api/v1/friendship_requests",
             params: { friendship_request: { accepter_id: other_user.id } }.to_json,
             headers: headers
      }.to change(Friendship, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["status"]).to eq("pending")
    end
  end

  describe "PUT /api/v1/friendship_requests/:id" do
    let(:request) { create(:friendship, requester: other_user, accepter: user, status: :pending) }

    it "accepts the request" do
      put "/api/v1/friendship_requests/#{request.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["status"]).to eq("accepted")
    end
  end

  describe "DELETE /api/v1/friendship_requests/:id" do
    let!(:request) { create(:friendship, requester: other_user, accepter: user, status: :pending) }

    it "rejects the request" do
      expect {
        delete "/api/v1/friendship_requests/#{request.id}", headers: headers
      }.to change(Friendship, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
