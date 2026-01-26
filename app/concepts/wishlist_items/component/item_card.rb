# frozen_string_literal: true

module WishlistItems
  module Component
    class ItemCard < Base::Component::Base
      def initialize(wishlist_item:)
        @wishlist_item = wishlist_item
      end

      def formatted_price
        case @wishlist_item.currency
        when "UAH"
          helpers.number_to_currency(@wishlist_item.price, unit: "₴", format: "%n %u", strip_insignificant_zeros: true)
        when "EUR"
          helpers.number_to_currency(@wishlist_item.price, unit: "€", format: "%u%n", strip_insignificant_zeros: true)
        else
          helpers.number_to_currency(@wishlist_item.price, unit: "$", format: "%u%n", strip_insignificant_zeros: true)
        end
      end
      def booked?
        @wishlist_item.booked?
      end

      def booked_by_me?
        booked? && @wishlist_item.booked_by_user == helpers.current_user
      end

      def can_book?
        !booked? && @wishlist_item.user != helpers.current_user
      end
    end
  end
end
