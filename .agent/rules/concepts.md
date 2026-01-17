---
alwaysApply: true
---

# Concepts Rules

## Overview
The `app/concepts/` directory contains feature-based code organization. Each feature has its own directory with operations and components.

## Directory Structure

```
app/concepts/
  feature_name/           # e.g., friends, users, home
    operation/            # Business logic operations
      index.rb
      show.rb
      create.rb
      update.rb
      destroy.rb
    component/            # UI components
      index.rb
      index.slim
      show.rb
      show.slim
      new.rb
      new.slim
```

## Naming Conventions

### Operations
- **Location**: `app/concepts/feature_name/operation/action_name.rb`
- **Class Name**: `FeatureName::Operation::ActionName`
- **Inherits**: `Base::Operation::Base`

**Example**:
- File: `app/concepts/friends/operation/index.rb`
- Class: `Friends::Operation::Index < Base::Operation::Base`

### Components
- **Location**: `app/concepts/feature_name/component/name.rb`
- **Class Name**: `FeatureName::Component::Name`
- **Template**: `app/concepts/feature_name/component/name.slim`
- **Inherits**: `Base::Component::Base`

**Example**:
- File: `app/concepts/friends/component/index.rb`
- Class: `Friends::Component::Index < Base::Component::Base`
- Template: `app/concepts/friends/component/index.slim`

## Operations

### Purpose
Operations contain business logic, data processing, and authorization.

### Structure
```ruby
# frozen_string_literal: true

class FeatureName::Operation::ActionName < Base::Operation::Base
  def perform!(params:, current_user:)
    # 1. Authorization
    authorize! Model, :action_name?
    
    # 2. Business logic
    # Load data, process, validate, etc.
    
    # 3. Set model for component
    self.model = result_data
  end
end
```

### Key Requirements
- **Must implement `perform!` method**
- **Must accept `params:` and `current_user:` keywords**
- **Must call `authorize!` or `policy_scope`** (for authorization)
- **Must set `self.model`** (data to pass to component)

### Example: Index Operation
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

### Example: Create Operation
```ruby
class Friends::Operation::Create < Base::Operation::Base
  def perform!(params:, current_user:)
    friendship = Friendship.new(friendship_params(params))
    friendship.requester = current_user
    
    authorize! friendship, :create?
    
    friendship.save!
    
    self.model = friendship
    self.redirect_path = friends_path
  end
  
  private
  
  def friendship_params(params)
    params.require(:friendship).permit(:accepter_id, :message)
  end
end
```

## Components

### Purpose
Components handle UI rendering. They are ViewComponents that receive data from operations.

### Structure
```ruby
# frozen_string_literal: true

class FeatureName::Component::Name < Base::Component::Base
  def initialize(model_name:)
    @model_name = model_name
  end
end
```

### Key Requirements
- **Must inherit from `Base::Component::Base`**
- **Initialize method receives data from operation**
- **Template file must exist** at `app/concepts/feature_name/component/name.slim`

### Example: Index Component
```ruby
class Friends::Component::Index < Base::Component::Base
  def initialize(friendships:)
    @friendships = friendships
  end
end
```

Corresponding template at `app/concepts/friends/component/index.slim`:
```slim
.container
  h1 My Friends
  
  - @friendships.each do |friendship|
    .card
      = friendship.requester.name
      = friendship.accepter.name
```

## How Operation + Component Work Together

### 1. Controller calls endpoint
```ruby
class FriendsController < ApplicationController
  def index
    endpoint Friends::Operation::Index, Friends::Component::Index
  end
end
```

### 2. Operation executes
```ruby
class Friends::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! Friendship, :index?
    self.model = policy_scope(Friendship).accepted
  end
end
```
- Receives `params` and `current_user`
- Performs authorization
- Loads and processes data
- Returns result with `model` set

### 3. Component receives data
The `endpoint` method extracts the model from operation result and passes it to component:

For **index** action:
```ruby
# Operation sets: self.model = collection
# Component receives: FeatureName::Component::Index.new(feature_names: collection)
```

For **show/edit/new** actions:
```ruby
# Operation sets: self.model = single_record
# Component receives: FeatureName::Component::Show.new(feature_name: single_record)
```

### 4. Component renders template
Component instance variables are available in the Slim template.

## Parameter Naming Convention

The `endpoint` method automatically determines parameter names:

### For Index Actions (collections)
- Takes operation class name first part
- Pluralizes it
- Uses as keyword parameter

**Example**:
- Operation: `Friends::Operation::Index`
- Extracts: `"Friends"`
- Converts to: `"friends"` (pluralized, underscored)
- Component receives: `friendships: [...]`

### For Show/Edit/New Actions (single records)
- Takes operation class name first part
- Singularizes it
- Uses as keyword parameter

**Example**:
- Operation: `Friends::Operation::Show`
- Extracts: `"Friends"`
- Converts to: `"friend"` (singularized, underscored)
- Component receives: `friend: <Friendship>`

## Complete Feature Example

### 1. Route
```ruby
resources :friends, only: [:index]
```

### 2. Controller
```ruby
class FriendsController < ApplicationController
  before_action :authenticate_user!
  
  def index
    endpoint Friends::Operation::Index, Friends::Component::Index
  end
end
```

### 3. Policy
```ruby
class FriendshipPolicy < ApplicationPolicy
  def index?
    user.present?
  end
  
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where("requester_id = ? OR accepter_id = ?", user.id, user.id)
    end
  end
end
```

### 4. Operation
```ruby
# app/concepts/friends/operation/index.rb
class Friends::Operation::Index < Base::Operation::Base
  def perform!(params:, current_user:)
    authorize! Friendship, :index?
    
    self.model = policy_scope(Friendship)
                   .accepted
                   .includes(:requester, :accepter)
  end
end
```

### 5. Component
```ruby
# app/concepts/friends/component/index.rb
class Friends::Component::Index < Base::Component::Base
  def initialize(friendships:)
    @friendships = friendships
  end
end
```

### 6. Template
```slim
/ app/concepts/friends/component/index.slim
.container
  h1= t('friends.index.title')
  
  .row
    - @friendships.each do |friendship|
      .col-md-4
        .card
          .card-body
            h5.card-title= friendship.accepter.name
            p.card-text= friendship.message
```

## Key Points

- **One feature = one directory** in `app/concepts/`
- **Operations handle logic**, components handle UI
- **Operations must call `authorize!` or `policy_scope`**
- **Operations set `self.model`** to pass data to components
- **Components receive data via `initialize` parameters**
- **Template files use Slim format**
- **Keep operations focused** - one operation per action
- **Reuse components** when appropriate (e.g., shared navbar)

## Shared Components

Shared components (used across features) go in `app/concepts/shared/`:

```
app/concepts/shared/
  navbar/
    component/
      show.rb
      show.slim
```

These can be rendered from layouts or other components.
