# frozen_string_literal: true

# Base policy class that all other policies inherit from
# Provides default authorization rules that deny all actions by default
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  # Default scope for index actions
  # Override in specific policies to customize record filtering
  def index?
    false
  end

  # Default policy for show action
  def show?
    false
  end

  # Default policy for create action
  def create?
    false
  end

  # Default policy for new action (typically same as create)
  def new?
    create?
  end

  # Default policy for update action
  def update?
    false
  end

  # Default policy for edit action (typically same as update)
  def edit?
    update?
  end

  # Default policy for destroy action
  def destroy?
    false
  end

  # Scope class for filtering collections
  # Override in specific policies to customize scoping logic
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # Default scope returns none
    # Override in specific policies to return filtered records
    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end
  end
end
