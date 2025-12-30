# frozen_string_literal: true

class ShoppingListPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.present? && record.accessible_by?(user)
  end

  def create?
    user.present?
  end

  def update?
    user.present? && record.owned_by?(user)
  end

  def destroy?
    user.present? && record.owned_by?(user)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user.present?

      scope.left_joins(:shopping_list_users)
           .where("shopping_lists.owner_id = ? OR shopping_list_users.user_id = ?", user.id, user.id)
           .distinct
    end
  end
end
