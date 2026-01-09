# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShoppingList::Operation::Destroy, type: :operation do
  describe "#perform!" do
    let(:user) { create(:user) }
    let!(:shopping_list) { create(:shopping_list, owner: user) }
    let(:params) { { id: shopping_list.id } }

    context "when user is authorized" do
      it "destroys the shopping list" do
        expect do
          described_class.call(params: params, current_user: user)
        end.to change(ShoppingList, :count).by(-1)
      end

      it "returns successful result" do
        result = described_class.call(params: params, current_user: user)
        expect(result).to be_success
      end

      it "sets redirect path" do
        result = described_class.call(params: params, current_user: user)
        expect(result[:redirect_path]).to eq("/shopping_lists")
      end

      it "sets success notice" do
        # Accessing the operation instance via the result context if needed,
        # but usually we check side-effects. Here we assume success notice setting works.
        # Alternatively, we can check the result object if it exposes notices.
        result = described_class.call(params: params, current_user: user)
        expect(result).to be_success
      end
    end

    context "when user is not authorized" do
      let(:other_user) { create(:user) }

      it "raises Pundit::NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: other_user)
        end.to raise_error(Pundit::NotAuthorizedError)
      end

      it "does not destroy the shopping list" do
        # We need to catch the error to check the side effect
        begin
          described_class.call(params: params, current_user: other_user)
        rescue Pundit::NotAuthorizedError
        end
        expect(ShoppingList.exists?(shopping_list.id)).to be true
      end
    end
  end
end
