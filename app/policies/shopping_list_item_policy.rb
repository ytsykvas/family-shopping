# frozen_string_literal: true

class ShoppingListItemPolicy < ApplicationPolicy
  def index?
    user.present? && record.list_accessible_by?(user)
  end

  def show?
    user.present? && record.list_accessible_by?(user)
  end

  def create?
    user.present? && record.list_accessible_by?(user)
  end

  def update?
    user.present? && record.list_accessible_by?(user)
  end

  def destroy?
    user.present? && record.list_accessible_by?(user)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user.present?

      scope.joins(:shopping_list)
           .left_joins(shopping_list: :shopping_list_users)
           .where("shopping_lists.owner_id = ? OR shopping_list_users.user_id = ?", user.id, user.id)
           .distinct
    end
  end
end
