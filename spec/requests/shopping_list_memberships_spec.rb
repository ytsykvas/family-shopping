require 'rails_helper'

RSpec.describe "ShoppingListMemberships", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: other_user) }
  let!(:membership) { create(:shopping_list_user, shopping_list: shopping_list, user: user) }

  before do
    sign_in user
  end

  describe "DELETE /shopping_list_memberships/:id" do
      it "removes the user from the shopping list" do
        expect {
          delete shopping_list_membership_path(membership)
        }.to change(shopping_list.members, :count).by(-1)

        expect(response).to redirect_to(shopping_lists_path)
      end
  end
end
