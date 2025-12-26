---
alwaysApply: true
---

# Testing Rules

## General Principles
- Use **RSpec** for all tests
- Follow **best practices** for testing
- Use **FactoryBot** with **Faker** for test data generation
- Use **Shoulda Matchers** for validation tests when possible
- **Stub external API calls** - any external API calls must be stubbed
- Use **let** or **let!** for repeated objects

## I18n in Tests
- **ALWAYS use I18n.t() for error messages** instead of hardcoded text
- Never check for specific error message text directly (e.g., "has already been taken")
- Use I18n keys to verify error messages: `expect(errors[:field]).to include(I18n.t("activerecord.errors.models.model_name.attributes.field_name.error_type"))`
- This ensures tests work regardless of the current locale (en/uk)

## Test Organization
- Use **describe** and **context** blocks for logical grouping
- Use **let** for lazy initialization
- Use **let!** for immediate initialization (when needed in before hooks)
- Group related tests together

## Factory Usage
- Use factories instead of creating objects manually
- Use traits for variations of the same model
- Use sequences for unique attributes when needed

## Best Practices
- Test both positive and negative cases
- Use descriptive test names
- Keep tests focused and isolated
- Avoid testing implementation details, test behavior
- Use shared examples for repeated test patterns when appropriate
