# frozen_string_literal: true

module WishlistItems
  module Component
    class Create < Base::Component::Base
      def initialize(new_wishlist_item:)
        @new_wishlist_item = new_wishlist_item
      end
    end
  end
end
