# frozen_string_literal: true

require "rails_helper"

RSpec.describe WishlistItems::Operation::Create, type: :operation do
  describe "#perform!" do
    let(:user) { create(:user) }
    let(:valid_params) do
      ActionController::Parameters.new({
        wishlist_item: {
          title: "New Gadget",
          price: 99.99,
          currency: "USD",
          description: "Cool device",
          url: "http://example.com/gadget"
        }
      })
    end

    context "with valid params" do
      it "creates a new wishlist item" do
        expect do
          described_class.call(params: valid_params, current_user: user)
        end.to change(WishlistItem, :count).by(1)
      end

      it "assigns attributes correctly" do
        result = described_class.call(params: valid_params, current_user: user)
        item = result.model
        expect(item.title).to eq("New Gadget")
        expect(item.price).to eq(99.99)
        expect(item.currency).to eq("USD")
        expect(item.user).to eq(user)
      end

      it "returns success" do
        result = described_class.call(params: valid_params, current_user: user)
        expect(result).to be_success
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        ActionController::Parameters.new({
          wishlist_item: {
            title: "" # title is required
          }
        })
      end

      it "does not create an item" do
        expect do
          described_class.call(params: invalid_params, current_user: user)
        end.not_to change(WishlistItem, :count)
      end

      it "returns failure" do
        result = described_class.call(params: invalid_params, current_user: user)
        expect(result).to be_failure
      end
    end
  end
end
