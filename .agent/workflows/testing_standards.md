---
description: Testing standards using RSpec, FactoryBot, and Faker
---

# Testing Standards

## Principles
1. **RSpec**: Use for all tests.
2. **Factories**: Use `FactoryBot` with `Faker`. Avoid manual object creation.
3. **I18n in Tests**: Always use `I18n.t()` when testing for error messages. Never hardcode message text.
4. **API Mocks**: Always stub external API calls.

## Structure
- Use `describe` for methods/actions.
- Use `context` for different states (e.g., `when user is admin`).
- Use `let` for lazy initialization.

### Example
```ruby
describe Friends::Operation::Create do
  let(:user) { create(:user) }
  
  context "when params are valid" do
    it "creates a friendship" do
      # ...
    end
  end
end
```
