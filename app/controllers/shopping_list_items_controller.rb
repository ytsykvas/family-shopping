# frozen_string_literal: true

class ShoppingListItemsController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_policy_scoped

  def create
    endpoint ShoppingListItem::Operation::Create
  end

  def update
    endpoint ShoppingListItem::Operation::Update
  end

  def destroy
    endpoint ShoppingListItem::Operation::Destroy
  end
end
