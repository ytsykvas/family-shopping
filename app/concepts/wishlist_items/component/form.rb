# frozen_string_literal: true

class WishlistItems::Component::Form < Base::Component::Base
  def initialize(wishlist_item:, modal_id:, title:, submit_text:, url:, method: nil)
    @wishlist_item = wishlist_item
    @modal_id = modal_id
    @title = title
    @submit_text = submit_text
    @url = url
    @method = method
  end
end
