# frozen_string_literal: true

module WishlistItems
  module Operation
    class Create < Base::Operation::Base
      def perform!(params:, current_user:)
        wishlist_item = current_user.wishlist_items.new(wishlist_item_params(params))
        authorize! wishlist_item, :create?

        if wishlist_item.save
          self.model = wishlist_item
          self.redirect_path = "/wishlist_items"
          notice(I18n.t("wishlist_items.create.success", default: "Item added successfully"), level: :success)
        else
          self.redirect_path = "/wishlist_items"
          add_errors(wishlist_item.errors)
          invalid!
        end
      end

      private

      def wishlist_item_params(params)
        params.require(:wishlist_item).permit(:title, :description, :url, :price, :currency, :image)
      end
    end
  end
end
