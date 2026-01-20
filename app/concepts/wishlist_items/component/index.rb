# frozen_string_literal: true

module WishlistItems
  module Component
    class Index < Base::Component::Base
      def initialize(wishlist_items:, new_wishlist_item:)
        @wishlist_items = wishlist_items
        @new_wishlist_item = new_wishlist_item
      end
    end
  end
end
