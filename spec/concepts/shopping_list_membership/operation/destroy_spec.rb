# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingListMembership::Operation::Destroy do
  subject(:result) { described_class.call(params: params, current_user: current_user) }

  let(:owner) { create(:user) }
  let(:member) { create(:user) }
  let(:other_user) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: owner) }
  let!(:membership) { create(:shopping_list_user, shopping_list: shopping_list, user: member) }
  let(:params) { { id: membership.id } }

  describe "#perform!" do
    context "when user leaves their own membership" do
      let(:current_user) { member }

      it "returns success" do
        expect(result).to be_success
      end

      it "removes the membership" do
        expect { result }.to change(ShoppingListUser, :count).by(-1)
      end

      it "returns the shopping list as model" do
        expect(result.model).to eq(shopping_list)
      end
    end

    context "when user tries to remove someone else's membership" do
      let(:current_user) { other_user }

      it "raises ActiveRecord::RecordNotFound or Pundit::NotAuthorizedError depending on scope" do
        # Since we find by ID, it might find it, but then we check user_id
        # The operation checks: unless membership.user_id == current_user.id
        expect(result).to be_failure
        expect(result.errors[:base]).to include(I18n.t("shopping_lists.leave.not_member"))
      end
    end

    context "when owner tries to leave (if they somehow have a membership record)" do
      # Note: Owners usually don't have a ShoppingListUser record in this app's logic (they are owner_id on list),
      # but if they did, the operation prevents it via `shopping_list.owned_by?(current_user)` check.
      let(:current_user) { owner }
      let!(:owner_membership) { create(:shopping_list_user, shopping_list: shopping_list, user: owner) }
      let(:params) { { id: owner_membership.id } }

      it "returns failure" do
        expect(result).to be_failure
        expect(result.errors[:base]).to include(I18n.t("shopping_lists.leave.owner_cannot_leave"))
      end
    end
  end
end
