# frozen_string_literal: true

class WishlistItems::Component::Show < Base::Component::Base
  def initialize(wishlist_items:, new_wishlist_item:, target_user:)
    @wishlist_items = wishlist_items
    @target_user = target_user
  end

  def title
    I18n.t("wishlist_items.show.title", name: @target_user.nickname)
  end

  def show_add_friend_button?
    return true unless helpers.user_signed_in?

    current_user = helpers.current_user
    return false if current_user == @target_user
    return false if current_user.friends_with?(@target_user)
    return false if current_user.pending_friend_request_to?(@target_user)
    return false if current_user.pending_friend_request_from?(@target_user)

    true
  end
end
