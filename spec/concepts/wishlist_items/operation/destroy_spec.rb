# frozen_string_literal: true

require "rails_helper"

RSpec.describe WishlistItems::Operation::Destroy, type: :operation do
  describe "#perform!" do
    let(:user) { create(:user) }
    let!(:wishlist_item) { create(:wishlist_item, user: user) }
    let(:params) { { id: wishlist_item.id } }

    context "when authorized" do
      it "deletes the wishlist item" do
        expect do
          described_class.call(params: params, current_user: user)
        end.to change(WishlistItem, :count).by(-1)
      end

      it "returns success" do
        result = described_class.call(params: params, current_user: user)
        expect(result).to be_success
      end
    end

    context "when not authorized" do
      let(:other_user) { create(:user) }

      it "raises NotAuthorizedError" do
        expect do
          described_class.call(params: params, current_user: other_user)
        end.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end
end
