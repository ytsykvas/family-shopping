---
alwaysApply: true
---

# Policy Rules (Pundit)

## Overview
The application uses Pundit for authorization. Policies control what users can and cannot do with resources.

## Policy Structure

### Location
`app/policies/`

### Naming Convention
- Policy class name: `ModelNamePolicy` (e.g., `FriendshipPolicy` for `Friendship` model)
- Inherits from `ApplicationPolicy`

### Basic Structure
```ruby
class ModelNamePolicy < ApplicationPolicy
  def index?
    # Return true if user can view list
  end

  def show?
    # Return true if user can view this record
  end

  def create?
    # Return true if user can create new record
  end

  def update?
    # Return true if user can update this record
  end

  def destroy?
    # Return true if user can delete this record
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      # Return scope of records user can access
    end
  end
end
```

## Policy Methods

### Standard Actions
- `index?` - Can view list of records
- `show?` - Can view a specific record
- `create?` - Can create new record
- `update?` - Can update a record
- `destroy?` - Can delete a record

### Custom Actions
You can define any custom action methods:
```ruby
def accept?
  user.present? && record.accepter_id == user.id && record.pending?
end

def reject?
  user.present? && record.accepter_id == user.id && record.pending?
end
```

## Policy Scope

### Purpose
Filter collections based on user permissions.

### Implementation
```ruby
class Scope < ApplicationPolicy::Scope
  def resolve
    if user.present?
      # Return filtered scope
      scope.where("requester_id = ? OR accepter_id = ?", user.id, user.id)
    else
      scope.none
    end
  end
end
```

### Usage in Operations
```ruby
def perform!(params:, current_user:)
  # policy_scope automatically uses the Scope class
  self.model = policy_scope(Friendship).where(status: :accepted)
end
```

## Using Policies in Operations

### Authorization Check
```ruby
def perform!(params:, current_user:)
  # Check if user can perform index action on Friendship
  authorize! Friendship, :index?
  
  # Rest of logic
end
```

### With Record
```ruby
def perform!(params:, current_user:)
  friendship = Friendship.find(params[:id])
  
  # Check if user can accept this specific friendship
  authorize! friendship, :accept?
  
  # Perform action
  friendship.update!(status: :accepted)
end
```

### Policy Scope
```ruby
def perform!(params:, current_user:)
  # Automatically filters based on Scope#resolve
  self.model = policy_scope(Friendship).where(status: :pending)
end
```

## Example: FriendshipPolicy

```ruby
class FriendshipPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def accept?
    user.present? && record.accepter_id == user.id && record.pending?
  end

  def reject?
    user.present? && record.accepter_id == user.id && record.pending?
  end

  def destroy?
    user.present? && (record.requester_id == user.id || record.accepter_id == user.id)
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
```

## Available Variables in Policy

### `user`
The current user (from `current_user` in controller/operation)

### `record`
The model instance being authorized (for show/update/destroy actions)

### `scope`
The model scope (in Scope class)

## Key Points

- **Always check `user.present?`** before checking user attributes
- **Use policy_scope for collections** - it automatically filters based on permissions
- **Use authorize! for single records** - it checks specific permissions
- **Policies should be simple** - complex business logic belongs in operations or services
- **Return boolean values** from policy methods (true/false)
- **Scope#resolve must return an ActiveRecord relation**, not an array