require "rails_helper"

RSpec.describe "ShoppingListMemberships", type: :request do
  let(:owner) { create(:user) }
  let(:member) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: owner) }
  let(:headers) { authenticated_header(member) }

  before do
    create(:shopping_list_user, shopping_list: shopping_list, user: member)
  end

  describe "DELETE /api/v1/shopping_list_memberships/:id" do
    it "leaves the shopping list" do
      membership = ShoppingListUser.find_by(shopping_list: shopping_list, user: member)

      expect {
        delete "/api/v1/shopping_list_memberships/#{membership.id}", headers: headers
      }.to change(ShoppingListUser, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
