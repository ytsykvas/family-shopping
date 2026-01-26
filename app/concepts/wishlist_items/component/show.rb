# frozen_string_literal: true

module WishlistItems
  module Component
    class Show < Base::Component::Base
      def initialize(wishlist_items:, new_wishlist_item:, target_user:)
        @wishlist_items = wishlist_items
        @target_user = target_user
      end

      def title
        I18n.t("wishlist_items.show.title", name: @target_user.nickname)
      end
    end
  end
end
