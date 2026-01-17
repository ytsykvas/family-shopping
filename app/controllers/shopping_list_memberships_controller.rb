# frozen_string_literal: true

class ShoppingListMembershipsController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_policy_scoped

  def destroy
    endpoint ShoppingListMembership::Operation::Destroy
  end
end
