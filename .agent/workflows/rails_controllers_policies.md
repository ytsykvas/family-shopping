---
description: Conventions for RESTful Controllers and Pundit Policies
---

# Controllers & Policies

## Controllers

### Rules
1. **Thin Controllers**: All business logic goes into Operations.
2. **Standard Actions**: Only use `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`.
3. **No Custom Actions**: Create a new controller instead.
    - ❌ **Bad**: `FriendsController#search_users`
    - ✅ **Good**: `UserSearchesController#index`
4. **Endpoint Helper**: Use `endpoint(OpClass, CompClass)` to connect everything.
5. **Turbo Streams (endpoint_partial)**:
    - Use `endpoint_partial(OpClass, CompClass, target_id: "dom_id")` (Recommended) or `endpoint_partial(OpClass, "partial", target_id: "dom_id")`.
    - **Authorization**: The helper automatically handles `check_authorization_is_called`.
    - **Data Flow**: The operation should return a Hash (e.g., `{ key: value }`) which is passed as keyword arguments to the Component or locals to the Partial.
    - **When to use**: Search results, autocomplete, dynamic content updates.

### Component vs Partial (in endpoint_partial)
- **Component (Preferred)**: Better testability, type-safe parameters.
- **Partial**: Only for very simple markup or legacy code.

### Example
```ruby
class FriendsController < ApplicationController
  def index
    endpoint Friends::Operation::Index, Friends::Component::Index
  end
end
```

## Policies (Pundit)

### Rules
1. **Location**: `app/policies/ModelNamePolicy.rb`.
2. **Check User**: Always check `user.present?` first.
3. **Scope**: Use `class Scope` for collection filtering.
4. **Simple Logic**: Complex checks belong in Operations, not Policies.

### Example
```ruby
class FriendshipPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user ? scope.where("requester_id = ? OR accepter_id = ?", user.id, user.id) : scope.none
    end
  end
end
```
