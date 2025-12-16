# frozen_string_literal: true

class FriendshipPolicy < ApplicationPolicy
  def index?
    user.present?
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
