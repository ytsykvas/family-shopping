# frozen_string_literal: true

module WishlistItems
  module Operation
    class Index < Base::Operation::Base
      def perform!(params:, current_user:)
        authorize! WishlistItem, :index?

        wishlist_items = policy_scope(WishlistItem).where(user: current_user).with_attached_image.order(created_at: :desc)

        self.model = OpenStruct.new(
          wishlist_items: wishlist_items,
          new_wishlist_item: current_user.wishlist_items.new,
          target_user: current_user
        )
      end
    end
  end
end
