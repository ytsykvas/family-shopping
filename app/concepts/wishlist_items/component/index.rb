# frozen_string_literal: true

module WishlistItems
  module Component
    class Index < Base::Component::Base
      def initialize(wishlist_items:, new_wishlist_item:, target_user:)
        @wishlist_items = wishlist_items
        @new_wishlist_item = new_wishlist_item
        @target_user = target_user
      end

      def title
        if own_wishlist?
          I18n.t("wishlist_items.index.title")
        else
          "#{I18n.t('wishlist_items.index.title')} (#{@target_user.name})"
        end
      end

      def show_create_button?
        own_wishlist?
      end

      private

      def own_wishlist?
        @target_user == helpers.current_user
      end
    end
  end
end
