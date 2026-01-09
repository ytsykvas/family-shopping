# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingList::Operation::Update, type: :operation do
  describe "#perform!" do
    let(:user) { create(:user) }
    let(:shopping_list) { create(:shopping_list, owner: user, name: "Old Name") }
    let(:params) { { id: shopping_list.id, shopping_list: { name: "New Name" } } }

    context "when user is authorized" do
      it "updates the shopping list" do
        expect do
          described_class.call(params: params, current_user: user)
          shopping_list.reload
        end.to change(shopping_list, :name).from("Old Name").to("New Name")
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
      let(:invalid_params) { { id: shopping_list.id, shopping_list: { name: "" } } }

      it "does not update the shopping list" do
        expect do
          described_class.call(params: invalid_params, current_user: user)
          shopping_list.reload
        end.not_to change(shopping_list, :name)
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
      let(:other_user) { create(:user) }
      let(:other_params) { { id: shopping_list.id, shopping_list: { name: "Hacked Name" } } }

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: other_params, current_user: other_user)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
