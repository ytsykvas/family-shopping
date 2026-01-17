---
alwaysApply: true
---

# Base Classes Rules

## Overview
The application uses a layered architecture with base classes for Operations and Components.

## Base::Operation::Base

### Location
`app/concepts/base/operation/base.rb`

### Purpose
Base class for all business logic operations. Operations handle data processing, authorization, and business rules.

### Key Features
- **Authorization Integration**: Built-in Pundit integration via `authorize!` and `policy_scope` methods
- **Error Handling**: Automatic error collection and propagation
- **Result Object**: Returns a result object with model, errors, and metadata
- **Sub-operations**: Can run nested operations with `run_operation`

### Method Signature
All operations must implement `perform!` method with these parameters:
```ruby
def perform!(params:, current_user:)
  # Business logic here
end
```

### Common Methods

#### Authorization
- `authorize!(record, query)` - Check authorization using Pundit policy
- `policy_scope(scope)` - Filter scope using Pundit policy scope
- `skip_authorize` - Skip authorization check
- `skip_policy_scope` - Skip policy scope check

#### Model Management
- `self.model = value` - Set the model that will be passed to the component
- `model` - Get the current model

#### Error Handling
- `add_error(key, message)` - Add an error message
- `add_errors(from)` - Copy errors from another object
- `invalid!` - Mark operation as failed

#### Navigation
- `self.redirect_path = path` - Set redirect path for after operation completes
- `notice(text, level:)` - Add a flash notice

### Example Operation
```ruby
class Friends::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! Friendship, :index?
    
    self.model = policy_scope(Friendship)
                   .accepted
                   .includes(:requester, :accepter)
  end
end
```

## Base::Component::Base

### Location
`app/concepts/base/component/base.rb`

### Purpose
Base class for all ViewComponents. Components are responsible for rendering UI.

### Inheritance
Inherits from `ViewComponent::Base` and includes helper modules:
- `Base::Component::Helper`
- `Base::Component::FormattingHelper`

### Usage
Components receive data from operations and render Slim templates.

### Example Component
```ruby
class Friends::Component::Index < Base::Component::Base
  def initialize(friendships:)
    @friendships = friendships
  end
end
```

## Operation + Component Flow

### 1. Controller calls endpoint
```ruby
class FriendsController < ApplicationController
  def index
    endpoint Friends::Operation::Index, Friends::Component::Index
  end
end
```

### 2. Endpoint method (in OperationsMethods concern)
- Calls operation with `params:` and `current_user:`
- Operation performs business logic and authorization
- Returns result with model
- Passes model to component for rendering

### 3. Component renders
- Receives data from operation
- Renders corresponding Slim template
- Template located at `app/concepts/feature/component/name.slim`

## Operation + Partial/Component Flow (for AJAX/Turbo Stream)

### 1. Controller calls endpoint_partial
You can pass either a **partial path string** or a **component class**:

```ruby
# Option 1: Using a component (recommended)
class UserSearchesController < ApplicationController
  def index
    endpoint_partial UserSearches::Operation::Index, UserSearches::Component::Results, target_id: "user-search-results"
  end
end

# Option 2: Using a partial path string
class UserSearchesController < ApplicationController
  def index
    endpoint_partial UserSearches::Operation::Index, "user_searches/results", target_id: "user-search-results"
  end
end
```

### 2. Endpoint_partial method (in OperationsMethods concern)
- Calls operation with `params:` and `current_user:`
- Operation performs business logic and authorization
- Returns result with model (usually a Hash)
- Automatically handles `skip_authorization` and `skip_policy_scope` via `check_authorization_is_called`
- Detects if second parameter is a String (partial) or Class (component)

### 3. Rendering
**For Component:**
- Receives `result.model` as constructor parameters
- If `result.model` is a Hash, spreads as keyword arguments to component constructor
- Renders component at `app/concepts/feature_name/component/name.slim`
- For Turbo Stream: wraps in `turbo_stream.replace(target_id, html)`
- For HTML: renders component only (useful for AJAX)

**For Partial:**
- Receives locals from `result.model` (if Hash, spreads as locals; otherwise wraps in `model:` key)
- Renders partial at `app/views/feature_name/_partial_name.slim`
- For Turbo Stream: wraps in `turbo_stream.replace(target_id, html)`
- For HTML: renders partial only (useful for AJAX)

### When to Use endpoint_partial
- **AJAX search/filtering** - live updates without full page reload
- **Autocomplete** - dynamic suggestions as user types
- **Dynamic content updates** - update specific parts of the page
- **Component fragments** - when you need to render a component fragment without full page reload

### Component vs Partial in endpoint_partial
**Use Component (recommended):**
- Follows the project architecture consistently
- Better reusability and testability
- Type-safe parameters via constructor
- Keeps all feature code in `app/concepts/`

**Use Partial:**
- Very simple markup without logic
- Legacy code that hasn't been migrated yet
- Quick prototyping

### Operation for endpoint_partial
When using `endpoint_partial`, the operation should:
- Use `skip_authorize` if no specific authorization needed (just `authenticate_user!` in controller)
- Use `policy_scope` for data filtering (sets `result[:pundit_scope] = true`)
- Return model as **Hash** with meaningful keys that match component/partial parameters

```ruby
class UserSearches::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    skip_authorize  # Authorization via authenticate_user! in controller
    
    query = params[:query]&.strip
    users = policy_scope(User).where("nickname LIKE ?", "%#{query}%").limit(10)
    
    # Hash keys match component constructor parameters
    self.model = { query: query, users: users }
  end
end
```

**Corresponding Component:**
```ruby
class UserSearches::Component::Results < Base::Component::Base
  def initialize(query:, users:)
    @query = query
    @users = users
  end
end
```

## Key Points
- **Always implement `perform!`**, not `call` (call is defined in base class)
- **Always accept both `params:` and `current_user:`** even if not used
- **Use `self.model =`** to set data that will be passed to component
- **Use `authorize!` and `policy_scope`** for authorization
- **Operations should be thin** - complex logic should be in service objects or models
