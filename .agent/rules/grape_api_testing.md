# Grape API Testing Guide

## Test Structure

### 1. **Operation Tests** (Unit Tests)
Location: `spec/concepts/api/users/operation/`

Test business logic in Operations:
```ruby
describe Api::Users::Operation::CheckNickname do
  let(:params) { { nickname: "test" } }
  let(:result) { described_class.call(params: params) }
  
  it "checks availability" do
    expect(result.model[:available]).to be true
  end
end
```

### 2. **Request Specs** (Integration Tests)
Location: `spec/requests/api/v1/`

Test HTTP layer (routing, params, auth, serialization):
```ruby
describe "GET /api/v1/users/check_nickname" do
  it "returns 200" do
    get "/api/v1/users/check_nickname", params: { nickname: "test" }
    expect(response).to have_http_status(:ok)
  end
  
  it "returns JSON" do
    get "/api/v1/users/check_nickname", params: { nickname: "test" }
    json = JSON.parse(response.body)
    expect(json["available"]).to be true
  end
end
```

## Testing Authenticated Endpoints

### With JWT Token
```ruby
describe "GET /api/v1/protected_endpoint" do
  let(:user) { create(:user) }
  let(:token) { user_jwt_token(user) }
  
  context "with valid token" do
    it "returns 200" do
      get "/api/v1/protected_endpoint", 
          headers: { "Authorization" => "Bearer #{token}" }
      expect(response).to have_http_status(:ok)
    end
  end
  
  context "without token" do
    it "returns 401 unauthorized" do
      get "/api/v1/protected_endpoint"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

# Helper для JWT токена
def user_jwt_token(user)
  payload = user.jwt_payload
  secret = ENV.fetch("DEVISE_JWT_SECRET_KEY")
  JWT.encode(payload, secret, "HS256")
end
```

## Testing Parameter Validation

```ruby
context "when required param is missing" do
  it "returns 400 bad request" do
    get "/api/v1/users/check_nickname"
    expect(response).to have_http_status(:bad_request)
  end
  
  it "returns error message" do
    get "/api/v1/users/check_nickname"
    json = JSON.parse(response.body)
    expect(json["error"]).to eq("nickname is missing")
  end
end
```

## Testing Entity Serialization

```ruby
it "returns correct entity structure" do
  get "/api/v1/users/check_nickname", params: { nickname: "test" }
  json = JSON.parse(response.body)
  
  # Test entity fields
  expect(json).to have_key("available")
  expect(json).to have_key("message")
  expect(json["available"]).to be_in([true, false])
  expect(json["message"]).to be_a(String)
end
```

## Best Practices

1. **Separate concerns**: Operations test logic, Request specs test HTTP
2. **Use FactoryBot**: Always use factories, never manual object creation
3. **Use I18n**: Test messages with `I18n.t()`, never hardcoded strings
4. **Test all contexts**: Success, failure, missing params, auth
5. **Test HTTP codes**: 200, 400, 401, 422, etc.
6. **Test JSON structure**: Verify entity serialization works

## Example: Complete Test Coverage

```ruby
describe "GET /api/v1/users/check_nickname" do
  context "success cases" do
    # Test available nickname
    # Test taken nickname
  end
  
  context "validation" do
    # Test missing params
    # Test invalid params
  end
  
  context "authentication" do
    # Test public access (if applicable)
    # Test authenticated access
    # Test unauthorized
  end
  
  context "response format" do
    # Test JSON structure
    # Test entity fields
    # Test content type
  end
end
```
