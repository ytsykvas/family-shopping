# frozen_string_literal: true

module WishlistItems
  module Operation
    class Index < Base::Operation::Base
      def perform!(params:, current_user:)
        authorize! WishlistItem, :index?

        target_user = params[:user_id].present? ? User.find_by(id: params[:user_id]) : current_user

        raise ActiveRecord::RecordNotFound unless target_user

        wishlist_items = policy_scope(WishlistItem).where(user: target_user).with_attached_image.order(created_at: :desc).page(params[:page]).per(30)

        self.model = OpenStruct.new(
          wishlist_items: wishlist_items,
          new_wishlist_item: (current_user == target_user ? target_user.wishlist_items.new : nil),
          target_user: target_user
        )
      end
    end
  end
end
