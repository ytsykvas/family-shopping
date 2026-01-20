# frozen_string_literal: true

module WishlistItems
  module Component
    class Delete < Base::Component::Base
      def initialize(wishlist_item:)
        @wishlist_item = wishlist_item
      end
    end
  end
end
