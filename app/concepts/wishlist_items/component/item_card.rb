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
    end
  end
end
