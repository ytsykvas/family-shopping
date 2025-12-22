# frozen_string_literal: true

class FriendshipPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    user.present? && record.accepter_id == user.id && record.pending?
  end

  def destroy?
    user.present? && (record.requester_id == user.id || record.accepter_id == user.id) && record.pending?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.present?
        scope.where("requester_id = ? OR accepter_id = ?", user.id, user.id)
      else
        scope.none
      end
    end
  end
end
