class WishlistItemPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    true
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end

  def book?
    record.user != user
  end

  def unbook?
    record.booked? && record.booked_by_user == user
  end

  class Scope < Scope
    def resolve
      # For now, index shows my own items.
      # If we view others, we might need a param or different scope logic.
      # But usually 'index' is 'my collection'.
      scope.all
    end
  end
end
