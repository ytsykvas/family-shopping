# frozen_string_literal: true

# Policy for User model
class UserPolicy < ApplicationPolicy
  def show?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.present?
        scope.all
      else
        scope.none
      end
    end
  end
end
