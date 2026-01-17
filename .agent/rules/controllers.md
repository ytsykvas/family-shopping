---
alwaysApply: true
---

# Controllers Rules

## Overview
Controllers in this application are kept thin. They primarily route requests to Operations and Components.

## Controller Structure

### Location
`app/controllers/`

### Naming Convention
- Controller name: `PluralNameController` (e.g., `FriendsController`)
- Inherits from `ApplicationController`

### Basic Structure
```ruby
class FriendsController < ApplicationController
  before_action :authenticate_user!

  def index
    endpoint Friends::Operation::Index, Friends::Component::Index
  end
end
```

## The `endpoint` Method

### Purpose
The `endpoint` method (from `OperationsMethods` concern) connects Operations and Components.

### How It Works

1. **Calls the Operation**
   - Passes `params:` and `current_user:` to the operation
   - Operation performs business logic and authorization
   - Returns a result object

2. **Checks Authorization**
   - Verifies that operation called `authorize!` or `policy_scope`
   - Raises error if authorization was not performed

3. **Renders the Component**
   - Extracts model from operation result
   - Passes model to component
   - Renders component's Slim template

### Signature
```ruby
endpoint(operation_class, component_class)
```

### Example Flow
```ruby
# Controller
def index
  endpoint Friends::Operation::Index, Friends::Component::Index
end

# What happens:
# 1. Calls Friends::Operation::Index.call(params: params, current_user: current_user)
# 2. Operation returns result with model (e.g., list of friendships)
# 3. Passes model to Friends::Component::Index.new(friendships: model)
# 4. Renders app/concepts/friends/component/index.slim
```

## The `endpoint_partial` Method

### Purpose
The `endpoint_partial` method is used for AJAX/Turbo Stream updates when you need to render only a partial (not a full component). Perfect for search results, autocomplete, dynamic content updates.

### How It Works

1. **Calls the Operation**
   - Passes `params:` and `current_user:` to the operation
   - Operation performs business logic and authorization
   - Returns result with model

2. **Checks Authorization**
   - Automatically calls `check_authorization_is_called` to skip Pundit checks if operation already performed authorization

3. **Renders the Partial**
   - For Turbo Stream: renders partial and wraps in `turbo_stream.replace`
   - For HTML: renders partial only (useful for AJAX)
   - Passes `result.model` as locals to the partial

### Signature
```ruby
endpoint_partial(operation_class, partial_name, target_id: nil)
```

### Parameters
- `operation_class` - Operation class to call
- `partial_name` - Path to partial (e.g., "user_searches/results")
- `target_id` - DOM element ID to replace (for Turbo Stream)

### Example: Search with AJAX Updates
```ruby
# Controller
class UserSearchesController < ApplicationController
  before_action :authenticate_user!

  def index
    endpoint_partial UserSearches::Operation::Index, "user_searches/results", target_id: "user-search-results"
  end
end

# Operation
class UserSearches::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    skip_authorize  # No specific authorization needed, just authenticate_user!
    
    query = params[:query]&.strip
    users = policy_scope(User).where("nickname LIKE ?", "%#{query}%").limit(10)
    
    self.model = { query: query, users: users }
  end
end

# Partial: app/views/user_searches/_results.slim
- if query.present?
  - if users.any?
    - users.each do |user|
      .user-card = user.name
  - else
    .no-results No users found
```

### When to Use `endpoint_partial`

Use `endpoint_partial` when:
- Building search functionality with live results
- Updating parts of the page via AJAX/Turbo Stream
- Implementing autocomplete or dynamic filters
- Need to render only a small part of the page, not a full component

Use regular `endpoint` when:
- Rendering full pages
- Standard CRUD operations
- Need full component with all its logic

## Standard Controller Actions

### Index Action
```ruby
def index
  endpoint Operation::Index, Component::Index
end
```
- Lists records
- Operation should use `policy_scope` to filter records
- Component receives collection as parameter

### Show Action
```ruby
def show
  endpoint Operation::Show, Component::Show
end
```
- Shows a single record
- Operation should use `authorize!` to check permissions
- Component receives single record as parameter

### New Action
```ruby
def new
  endpoint Operation::New, Component::New
end
```
- Shows form for creating new record
- Operation creates an empty model object
- Component renders form

### Create Action
```ruby
def create
  endpoint Operation::Create, Component::New
end
```
- Creates new record
- Operation creates and saves record
- On success: redirects (operation sets `redirect_path`)
- On failure: re-renders form with errors

### Edit Action
```ruby
def edit
  endpoint Operation::Edit, Component::Edit
end
```
- Shows form for editing existing record
- Operation loads record and checks permissions
- Component renders form

### Update Action
```ruby
def update
  endpoint Operation::Update, Component::Edit
end
```
- Updates existing record
- Operation updates and saves record
- On success: redirects
- On failure: re-renders form with errors

### Destroy Action
```ruby
def destroy
  endpoint Operation::Destroy
end
```
- Deletes record
- No component needed (just redirects)
- Operation deletes record and sets redirect path

## Standard Actions Only

Controllers should **only** contain standard RESTful actions:
- `index` - list records
- `show` - show a single record
- `new` - form for creating a new record
- `create` - create a new record
- `edit` - form for editing an existing record
- `update` - update an existing record
- `destroy` - delete a record

### Avoiding Custom Actions

**Important:** If you feel the need to create a custom action (like `search_users`, `pending`, `accept`, etc.), **consider creating a new controller instead**.

**Example:**
Instead of:
```ruby
# ❌ Bad: Custom action in FriendsController
class FriendsController < ApplicationController
  def index
    endpoint Friends::Operation::Index, Friends::Component::Index
  end

  def search_users  # Custom action
    endpoint Friends::Operation::SearchUsers, Friends::Component::Search
  end
end
```

Consider:
```ruby
# ✅ Good: Separate controller for user search
class UserSearchesController < ApplicationController
  def index
    endpoint UserSearches::Operation::Index, UserSearches::Component::Index
  end
end
```

This keeps controllers focused and follows RESTful principles.

## Before Actions

### Authentication
```ruby
before_action :authenticate_user!
```
Requires user to be logged in (Devise method).

### Loading Resources
```ruby
before_action :set_friendship, only: [:show, :edit, :update, :destroy]

private

def set_friendship
  @friendship = Friendship.find(params[:id])
end
```
Load record before action (if needed, though operations usually handle this).

## Key Points

- **Keep controllers thin** - all business logic goes in operations
- **Always use `endpoint` method** to connect operations and components
- **Don't access models directly** in controllers - let operations handle it
- **Don't perform authorization** in controllers - let operations handle it via policies
- **Use `before_action :authenticate_user!`** for actions requiring authentication
- **Operations handle redirects** - controllers just call `endpoint`
- **Stick to standard CRUD actions** - controllers should only contain `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`
- **Avoid custom actions** - if you feel the need to create a custom action, consider creating a new controller instead

## Routes Configuration

Controllers are connected to routes in `config/routes.rb`:

```ruby
resources :friends, only: [:index] do
  collection do
    get :pending      # /friends/pending
  end
  member do
    post :accept      # /friends/:id/accept
    post :reject      # /friends/:id/reject
  end
end
```

## Complete Example

### Route
```ruby
resources :friends, only: [:index]
```

### Controller
```ruby
class FriendsController < ApplicationController
  before_action :authenticate_user!

  def index
    endpoint Friends::Operation::Index, Friends::Component::Index
  end
end
```

### Operation
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

### Component
```ruby
class Friends::Component::Index < Base::Component::Base
  def initialize(friendships:)
    @friendships = friendships
  end
end
```

### Template
`app/concepts/friends/component/index.slim`

This creates a complete working feature!
