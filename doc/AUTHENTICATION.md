# Authentication Setup

This application uses Devise with JWT for authentication, supporting both web sessions and API token-based authentication.

## Web Authentication

Web authentication uses standard Devise with sessions and cookies.

### Routes

- Sign up: `POST /users`
- Sign in: `POST /users/sign_in`
- Sign out: `DELETE /users/sign_out`
- Password reset: `POST /users/password`

### Usage in Controllers

```ruby
class PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    @posts = current_user.posts
  end
end
```

## API Authentication (JWT)

API authentication uses JWT tokens for React Native and other API clients.

### Configuration

JWT secret is stored in Rails credentials:
```bash
bin/rails credentials:edit
```

Add:
```yaml
devise_jwt_secret_key: your_secret_key_here
```

Or use environment variable:
```bash
DEVISE_JWT_SECRET_KEY=your_secret_key_here
```

### API Endpoints

#### Login
```bash
POST /users/sign_in
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}
```

Response includes JWT token in `Authorization` header:
```
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Authenticated Requests

Include the token in all subsequent requests:
```bash
GET /api/v1/posts
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

#### Logout
```bash
DELETE /users/sign_out
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

This revokes the token by adding it to the denylist.

### Usage in API Controllers

```ruby
class Api::V1::PostsController < Api::BaseController
  def index
    posts = policy_scope(Post)
    render json: posts
  end

  def create
    post = current_user.posts.create!(post_params)
    authorize post
    render json: post, status: :created
  end
end
```

## Token Management

### JWT Denylist

Revoked tokens are stored in the `jwt_denylists` table. The model includes a cleanup method:

```ruby
# Clean up expired tokens (run periodically via cron/sidekiq)
JwtDenylist.cleanup_expired
```

### Token Expiration

Tokens expire after 1 day by default. Configure in `config/initializers/devise.rb`:

```ruby
config.jwt do |jwt|
  jwt.expiration_time = 1.day.to_i
end
```

## Authorization with Pundit

Both web and API use Pundit for authorization:

```ruby
class PostPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def update?
    record.user_id == user.id
  end
end
```

## Testing Authentication

### RSpec Examples

```ruby
# Web authentication
RSpec.describe PostsController, type: :controller do
  let(:user) { create(:user) }
  
  before { sign_in user }
  
  it "lists user's posts" do
    get :index
    expect(response).to have_http_status(:success)
  end
end

# API authentication
RSpec.describe Api::V1::PostsController, type: :controller do
  let(:user) { create(:user) }
  let(:token) { generate_jwt_token(user) }
  
  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end
  
  it "lists posts" do
    get :index
    expect(response).to have_http_status(:success)
  end
end
```

## Future: Grape API Integration

When adding Grape API:

1. Mount Grape API in routes:
```ruby
mount API::Root => '/api'
```

2. Create authentication helper:
```ruby
module API
  module Helpers
    module AuthenticationHelper
      def authenticate!
        token = headers['Authorization']&.split(' ')&.last
        decoded = JWT.decode(token, jwt_secret, true, { algorithm: 'HS256' })
        @current_user = User.find(decoded.first['sub'])
      rescue
        error!('Unauthorized', 401)
      end
      
      def current_user
        @current_user
      end
    end
  end
end
```

3. Use in Grape endpoints:
```ruby
module API
  module V1
    class Posts < Grape::API
      helpers API::Helpers::AuthenticationHelper
      
      before { authenticate! }
      
      resource :posts do
        get do
          present current_user.posts, with: API::Entities::Post
        end
      end
    end
  end
end
```
