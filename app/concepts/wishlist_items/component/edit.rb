# frozen_string_literal: true

class WishlistItems::Component::Edit < Base::Component::Base
  def initialize(wishlist_item:)
    @wishlist_item = wishlist_item
  end
end
