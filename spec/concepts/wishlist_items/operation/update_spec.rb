# frozen_string_literal: true

require "rails_helper"

RSpec.describe WishlistItems::Operation::Update, type: :operation do
  describe "#perform!" do
    let(:user) { create(:user) }
    let!(:wishlist_item) { create(:wishlist_item, user: user, title: "Old Title") }
    let(:params) do
      ActionController::Parameters.new({
        id: wishlist_item.id,
        wishlist_item: {
          title: "New Title"
        }
      })
    end

    context "when authorized" do
      it "updates the wishlist item" do
        described_class.call(params: params, current_user: user)
        expect(wishlist_item.reload.title).to eq("New Title")
      end

      it "returns success" do
        result = described_class.call(params: params, current_user: user)
        expect(result).to be_success
      end
    end

    context "when not authorized (other user)" do
      let(:other_user) { create(:user) }

      it "raises NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: other_user)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        ActionController::Parameters.new({
          id: wishlist_item.id,
          wishlist_item: {
            title: ""
          }
        })
      end

      it "does not update the item" do
        described_class.call(params: invalid_params, current_user: user)
        expect(wishlist_item.reload.title).to eq("Old Title")
      end

      it "returns failure" do
        result = described_class.call(params: invalid_params, current_user: user)
        expect(result).to be_failure
      end
    end
  end
end
