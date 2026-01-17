require "rails_helper"

RSpec.describe "Friends", type: :request do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:headers) { authenticated_header(user) }

  before do
    create(:friendship, requester: user, accepter: friend, status: :accepted)
  end

  describe "GET /api/v1/friends" do
    it "returns list of friends" do
      get "/api/v1/friends", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json.count).to eq(1)
      expect(json.first["id"]).to eq(friend.id)
    end
  end

  describe "DELETE /api/v1/friends/:id" do
    it "removes a friend" do
      friendship = Friendship.find_by(requester: user, accepter: friend) || Friendship.find_by(requester: friend, accepter: user)
      expect {
        delete "/api/v1/friends/#{friendship.id}", headers: headers
      }.to change(Friendship, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
