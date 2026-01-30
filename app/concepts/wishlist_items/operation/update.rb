# frozen_string_literal: true

class WishlistItems::Operation::Update < Base::Operation::Base
  def perform!(params:, current_user:)
    wishlist_item = WishlistItem.find(params[:id])
    authorize! wishlist_item, :update?

    if wishlist_item.update(wishlist_item_params(params))
      self.model = wishlist_item
      self.redirect_path = "/wishlist_items"
      notice(I18n.t("wishlist_items.update.success"), level: :success)
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
