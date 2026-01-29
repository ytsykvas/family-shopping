# frozen_string_literal: true

class GlobalRecipe::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! :global_recipe, :index?
    skip_policy_scope

    scope = Recipe.all.includes(:user)

    if params[:name].present?
      scope = scope.where("name ILIKE ?", "%#{params[:name]}%")
    end

    if params[:ingredient].present?
      scope = scope.joins(:ingredients).where("ingredients.content ILIKE ?", "%#{params[:ingredient]}%").distinct
    end

    scope = scope.where.not(user: current_user).order(created_at: :desc).page(params[:page]).per(21)

    self.model = OpenStruct.new(global_recipes: scope, params: params)
  end
end
