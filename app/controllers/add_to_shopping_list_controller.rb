class AddToShoppingListController < ApplicationController
  before_action :authenticate_user!
  skip_after_action :verify_policy_scoped

  def create
    endpoint Recipe::Operation::AddToShoppingList
  end
end
