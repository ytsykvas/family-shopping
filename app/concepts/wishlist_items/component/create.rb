# frozen_string_literal: true

class WishlistItems::Component::Create < Base::Component::Base
  def initialize(new_wishlist_item:)
    @new_wishlist_item = new_wishlist_item
  end
end
