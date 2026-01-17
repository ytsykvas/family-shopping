# frozen_string_literal: true

class ShoppingListInvitationPolicy < ApplicationPolicy
  def create?
    return false unless user.present?
    return false unless record.shopping_list.present?

    record.shopping_list.owned_by?(user)
  end

  def update?
    user.present? && record.invitee_id == user.id
  end

  def destroy?
    return false unless user.present?

    record.inviter_id == user.id || record.invitee_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user.present?

      scope.joins(:shopping_list)
           .where("inviter_id = ? OR invitee_id = ?", user.id, user.id)
    end
  end
end
