# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingList::Operation::Index, type: :operation do
  describe "#perform!" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:params) { {} }

    context "when user is authorized" do
      before { user.owned_shopping_lists.destroy_all }

      # Create lists where user is owner
      let!(:owned_list1) { create(:shopping_list, owner: user, created_at: 1.day.ago) }
      let!(:owned_list2) { create(:shopping_list, owner: user, created_at: 1.hour.ago) }

      # Create list where user is member (shared with user)
      let!(:shared_list) { create(:shopping_list, owner: other_user) }
      let!(:shopping_list_user) { create(:shopping_list_user, shopping_list: shared_list, user: user) }

      # Create unrelated list
      let!(:unrelated_list) { create(:shopping_list, owner: other_user) }

      it "returns successful result" do
        result = described_class.call(params: params, current_user: user)
        expect(result).to be_success
      end

      it "returns shopping lists ordered by created_at desc" do
        result = described_class.call(params: params, current_user: user)
        lists = result.model.shopping_lists

        expect(lists).to match_array([ shared_list, owned_list2, owned_list1 ])
        # Check order
        expect(lists[0]).to eq(shared_list) # Newest (created now)
        expect(lists[1]).to eq(owned_list2) # 1 hour ago
        expect(lists[2]).to eq(owned_list1) # 1 day ago
      end

      it "excludes unrelated lists" do
        result = described_class.call(params: params, current_user: user)
        lists = result.model.shopping_lists
        expect(lists).not_to include(unrelated_list)
      end

      it "sets model in result" do
        result = described_class.call(params: params, current_user: user)
        expect(result.model).to be_present
        expect(result.model).to be_a(OpenStruct)
        expect(result.model.shopping_lists).to be_a(ActiveRecord::Relation)
      end
    end

    context "when user is not authorized" do
      let(:unauthorized_user) { nil }

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: unauthorized_user)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
