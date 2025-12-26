---
description: Coding standards and architecture for Operations and Components (Trailblazer-like pattern)
---

# Rails Architecture: Operations & Components

This project uses a layered architecture where business logic is encapsulated in **Operations** and UI logic in **Components** (ViewComponent + Slim).

## Directory Structure

```
app/concepts/
  feature_name/           # e.g., friends, users, home
    operation/            # Business logic operations
      index.rb, show.rb, create.rb, update.rb, destroy.rb
    component/            # UI components
      index.rb, index.slim, show.rb, show.slim
  shared/                 # Shared components (e.g., navbar)
    navbar/
      component/
        show.rb, show.slim
```

## Naming & Parameter Conventions (Automatic)
The `endpoint` helper automatically infers parameter names for the Component:
- **Index/Collection**: Pluralizes the name (e.g., `Friends::Operation::Index` -> `friendships: ...`).
- **Show/Single**: Singularizes the name (e.g., `Friends::Operation::Show` -> `friend: ...`).
```

## Operations

### Rules & Conventions
1. **Location**: `app/concepts/feature_name/operation/action_name.rb`
2. **Naming**: `FeatureName::Operation::ActionName < Base::Operation::Base`
3. **Execution**: Must implement `perform!(params:, current_user:)`.
4. **Authorization**: Must call `authorize!` (Pundit) or `policy_scope`.
5. **Data Flow**: Must set `self.model` to pass data to the component.
6. **Common Methods**:
    - `add_error(key, message)`: Add validation errors.
    - `add_errors(from)`: Copy errors from another object.
    - `invalid!`: Mark operation as failed.
    - `self.redirect_path = path`: Set redirect after success.
    - `notice(text, level:)`: Flash notice helper.
    - `run_operation(OpClass)`: Execute a nested operation.

### Example
```ruby
class Friends::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! Friendship, :index?
    self.model = policy_scope(Friendship).accepted
  end
end
```

## Components

### Rules & Conventions
1. **Location**: `app/concepts/feature_name/component/name.rb`
2. **Naming**: `FeatureName::Component::Name < Base::Component::Base`
3. **Template**: Must have a corresponding `.slim` file in the same directory.
4. **Initialization**: Receives data from the operation via keyword arguments.

### Example
```ruby
class Friends::Component::Index < Base::Component::Base
  def initialize(friendships:)
    @friendships = friendships
  end
end
```

## Integration (Flow)

1. **Controller** calls `endpoint Friends::Operation::Index, Friends::Component::Index`.
2. **Operation** executes, performs authorization, and sets `self.model`.
3. **Endpoint** helper automatically passes `self.model` to the Component as keyword arguments.
4. **Component** renders the `.slim` template.
