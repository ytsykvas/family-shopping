require 'rails_helper'

RSpec.describe "Friends", type: :request do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }

  before do
    sign_in user
    create(:friendship, requester: user, accepter: friend, status: :accepted)
  end

  describe "GET /friends" do
    it "returns http success" do
      get friends_path
      expect(response).to have_http_status(:success)
      # Check for localized title or just status if content varies
      expect(response.body).to include(I18n.t("friends.index.title"))
    end
  end

  describe "DELETE /friends/:id" do
     it "removes a friend" do
      # Ensure friendship is correctly set up
      friendship = Friendship.between_users(user, friend).first
      expect(friendship).to be_present

      expect {
        delete friend_path(friendship) # Use the friendship ID
      }.to change(Friendship, :count).by(-1)

      expect(response).to have_http_status(:redirect)
      expect(flash[:notice]).to eq(I18n.t("friends.destroy.success"))
    end
  end
end
