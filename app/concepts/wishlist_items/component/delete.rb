# frozen_string_literal: true

class WishlistItems::Component::Delete < Base::Component::Base
  def initialize(wishlist_item:)
    @wishlist_item = wishlist_item
  end
end
