# frozen_string_literal: true

class WishlistItemsController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]

  def index
    endpoint WishlistItems::Operation::Index, WishlistItems::Component::Index
  end

  def show
    endpoint WishlistItems::Operation::Show, WishlistItems::Component::Show
  end

  def create
    endpoint WishlistItems::Operation::Create
  end

  def update
    endpoint WishlistItems::Operation::Update
  end

  def destroy
    endpoint WishlistItems::Operation::Destroy
  end

  def book
    op = WishlistItems::Operation::Book.call(params: params, current_user: current_user)
    check_authorization_is_called op

    if op.success?
      redirect_back fallback_location: root_path, notice: I18n.t("wishlist_items.book.success")
    else
      redirect_back fallback_location: root_path, alert: op.error_message
    end
  end

  def unbook
    op = WishlistItems::Operation::Unbook.call(params: params, current_user: current_user)
    check_authorization_is_called op

    if op.success?
      redirect_back fallback_location: root_path, notice: I18n.t("wishlist_items.unbook.success")
    else
      redirect_back fallback_location: root_path, alert: op.error_message
    end
  end
end
