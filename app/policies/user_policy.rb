# frozen_string_literal: true

# Policy for User model
class UserPolicy < ApplicationPolicy
  # Any authenticated user can view the user list
  def index?
    user.present?
  end

  # Users can view their own profile
  def show?
    user.present? && (record == user || user.admin?)
  end

  # Anyone can create a new user (registration)
  def create?
    true
  end

  # Users can only update their own profile
  def update?
    user.present? && record == user
  end

  # Users can only delete their own account
  def destroy?
    user.present? && record == user
  end

  # Scope for filtering users
  class Scope < ApplicationPolicy::Scope
    def resolve
      # Regular users can only see themselves
      # Admins can see all users (when we add admin role)
      if user.present?
        scope.where(id: user.id)
      else
        scope.none
      end
    end
  end
end
