# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingList::Operation::Show do
  subject(:result) { described_class.call(params: params, current_user: current_user) }

  let(:owner) { create(:user) }
  let(:member) { create(:user) }
  let(:other_user) { create(:user) }
  let(:shopping_list) { create(:shopping_list, owner: owner) }
  let(:params) { { id: shopping_list.id } }

  describe "#perform!" do
    context "when user is the owner" do
      let(:current_user) { owner }

      it "returns success" do
        expect(result).to be_success
      end

      it "returns the shopping list" do
        expect(result.model.shopping_list).to eq(shopping_list)
      end
    end

    context "when user is a member" do
      let(:current_user) { member }

      before do
        create(:shopping_list_user, shopping_list: shopping_list, user: member)
      end

      it "returns success" do
        expect(result).to be_success
      end

      it "returns the shopping list" do
        expect(result.model.shopping_list).to eq(shopping_list)
      end
    end

    context "when user is neither owner nor member" do
      let(:current_user) { other_user }

      it "raises Pundit::NotAuthorizedError" do
        expect { result }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when user is nil" do
      let(:current_user) { nil }

      it "raises Pundit::NotAuthorizedError" do
        expect { result }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "when shopping list does not exist" do
      let(:current_user) { owner }
      let(:params) { { id: 999_999 } }

      it "raises ActiveRecord::RecordNotFound" do
        expect { result }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with associated data" do
      let(:current_user) { owner }
      let!(:item) { create(:shopping_list_item, shopping_list: shopping_list, added_by: owner) }

      before do
        create(:shopping_list_user, shopping_list: shopping_list, user: member)
      end

      it "includes members" do
        expect(result.model.shopping_list.members).to include(member)
      end

      it "includes items" do
        expect(result.model.shopping_list.shopping_list_items).to include(item)
      end
    end
  end
end
