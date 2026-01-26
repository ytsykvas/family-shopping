# frozen_string_literal: true

module WishlistItems
  module Operation
    class Show < Base::Operation::Base
      def perform!(params:, current_user:)
        authorize! WishlistItem, :index?

        target_user = User.find(params[:id])

        wishlist_items = policy_scope(WishlistItem).where(user: target_user).with_attached_image.order(created_at: :desc)

        self.model = OpenStruct.new(
          wishlist_items: wishlist_items,
          new_wishlist_item: nil,
          target_user: target_user
        )
      end
    end
  end
end
