class GlobalRecipePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def add?
    true
  end
end
