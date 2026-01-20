# frozen_string_literal: true

module WishlistItems
  module Operation
    class Destroy < Base::Operation::Base
      def perform!(params:, current_user:)
        wishlist_item = WishlistItem.find(params[:id])
        authorize! wishlist_item, :destroy?

        if wishlist_item.destroy
          self.redirect_path = "/wishlist_items"
          notice(I18n.t("wishlist_items.destroy.success", default: "Item removed successfully"), level: :success)
        else
          self.redirect_path = "/wishlist_items"
          add_error(:base, "Could not delete item")
          invalid!
        end
      end
    end
  end
end
