# frozen_string_literal: true

module WishlistItems
  module Operation
    class Book < Base::Operation::Base
      PRESENTS_LIST_NAME = "Presents"

      def perform!(params:, current_user:)
        wishlist_item = WishlistItem.find(params[:id])
        self.model = wishlist_item

        authorize! wishlist_item, :book?

        return unless validate_booking!(wishlist_item, current_user)

        ActiveRecord::Base.transaction do
          book_item!(wishlist_item, current_user)
          add_to_shopping_list!(wishlist_item, current_user)
        end
      end

      private

      def validate_booking!(item, user)
        if item.user == user
          add_error(:base, I18n.t("wishlist_items.book.errors.own_item"))
          invalid!
          return false
        end

        if item.booked?
          add_error(:base, I18n.t("wishlist_items.book.errors.already_booked"))
          invalid!
          return false
        end

        true
      end

      def book_item!(item, user)
        item.update!(
          status: :booked,
          booked_by_user: user
        )
      end

      def add_to_shopping_list!(wishlist_item, user)
        presents_list = find_or_create_presents_list(user)

        presents_list.shopping_list_items.create!(
          name: "#{wishlist_item.title} (#{wishlist_item.user.nickname})",
          added_by: user,
          status: "pending"
        )
      end

      def find_or_create_presents_list(user)
        user.owned_shopping_lists.find_or_create_by!(name: PRESENTS_LIST_NAME)
      end
    end
  end
end
