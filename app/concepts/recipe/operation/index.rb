# frozen_string_literal: true

class Recipe::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! Recipe, :index?

    self.model = policy_scope(Recipe).includes(:user).page(params[:page]).per(21)
  end
end
