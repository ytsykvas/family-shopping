# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingList::Operation::Create, type: :operation do
  describe "#perform!" do
    let!(:user) { create(:user) }
    let(:params) { { shopping_list: { name: "My New List" } } }

    context "when user is authorized" do
      it "creates a new shopping list" do
        expect do
          described_class.call(params: params, current_user: user)
        end.to change(ShoppingList, :count).by(1)
      end

      it "assigns the current user as owner" do
        result = described_class.call(params: params, current_user: user)
        shopping_list = result.model
        expect(shopping_list.owner).to eq(user)
        expect(shopping_list.name).to eq("My New List")
      end

      it "returns successful result" do
        result = described_class.call(params: params, current_user: user)
        expect(result).to be_success
      end

      it "sets redirect path" do
        result = described_class.call(params: params, current_user: user)
        expect(result[:redirect_path]).to eq("/shopping_lists")
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { shopping_list: { name: "" } } }

      it "does not create a shopping list" do
        expect do
          described_class.call(params: invalid_params, current_user: user)
        end.not_to change(ShoppingList, :count)
      end

      it "returns failure result" do
        result = described_class.call(params: invalid_params, current_user: user)
        expect(result).to be_failure
      end

      it "sets redirect path to index" do
        result = described_class.call(params: invalid_params, current_user: user)
        expect(result[:redirect_path]).to eq("/shopping_lists")
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
