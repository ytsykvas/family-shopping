# frozen_string_literal: true

class ShoppingListInvitationsController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_policy_scoped

  def create
    endpoint ShoppingListInvitation::Operation::Create
  end

  def update
    endpoint ShoppingListInvitation::Operation::Update
  end

  def destroy
    endpoint ShoppingListInvitation::Operation::Destroy
  end
end
