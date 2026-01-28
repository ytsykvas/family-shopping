class RecipePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.user == user
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

  def add_to_shopping_list?
    record.user == user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.recipes
    end
  end
end
