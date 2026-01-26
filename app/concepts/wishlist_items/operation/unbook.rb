# frozen_string_literal: true

module WishlistItems
  module Operation
    class Unbook < Base::Operation::Base
      PRESENTS_LIST_NAME = "Presents"

      def perform!(params:, current_user:)
        wishlist_item = WishlistItem.find(params[:id])
        self.model = wishlist_item

        authorize! wishlist_item, :unbook?

        return unless validate_unbooking!(wishlist_item, current_user)

        ActiveRecord::Base.transaction do
          unbook_item!(wishlist_item)
          remove_from_shopping_list!(wishlist_item, current_user)
        end
      end

      private

      def validate_unbooking!(item, user)
        unless item.booked? && item.booked_by_user == user
          add_error(:base, I18n.t("wishlist_items.unbook.errors.not_booked_by_you"))
          invalid!
          return false
        end

        true
      end

      def unbook_item!(item)
        item.update!(
          status: :pending,
          booked_by_user: nil
        )
      end

      def remove_from_shopping_list!(wishlist_item, user)
        presents_list = user.owned_shopping_lists.find_by(name: PRESENTS_LIST_NAME)
        return unless presents_list

        item_name = "#{wishlist_item.title} (#{wishlist_item.user.nickname})"
        presents_list.shopping_list_items.where(name: item_name).destroy_all
      end
    end
  end
end
