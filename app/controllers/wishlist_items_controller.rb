# frozen_string_literal: true

class WishlistItemsController < ApplicationController
  before_action :authenticate_user!

  def index
    endpoint WishlistItems::Operation::Index, WishlistItems::Component::Index
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
end
