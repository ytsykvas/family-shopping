---
alwaysApply: true
---

# Locales and Translations Rules

## General Principles
- **ALL user-facing text MUST be in locale files** - no hardcoded text in code
- Use `I18n.t` for translations (in views can use shorthand `t`)
- Each language in a separate file with language code (e.g., `en.yml`, `uk.yml`)

## File Structure
```
config/locales/
  en.yml           # English translations
  uk.yml           # Ukrainian translations
```

## Critical Formatting Rules

### 1. No Line Breaks in Translations
- **NEVER** split translations across multiple lines
- Keep translations on a single line, even if they are very long
- This is required for easier maintenance and comparison

**Bad:**
```yaml
en:
  long_message: "This is a very long message that
    continues on multiple lines"
```

**Good:**
```yaml
en:
  long_message: "This is a very long message that continues on a single line no matter how long it is"
```

### 2. Synchronized Line Count
- **All locale files for the same scope MUST have the same number of lines**
- This makes it easier to compare translations side-by-side
- Keep the same structure and order in all language files

**Example:**
```yaml
# en.yml (32 lines)
en:
  hello: "Hello world"
  welcome: "Welcome to our app"
  goodbye: "Goodbye"

# uk.yml (32 lines) - same structure, same line count
uk:
  hello: "Привіт світ"
  welcome: "Ласкаво просимо до нашого додатку"
  goodbye: "До побачення"
```

## Translation Usage

### In Ruby Code
```ruby
I18n.t('key')
I18n.t('nested.key')
I18n.t('key', name: 'John')  # with interpolation
```

### In Views (Slim)
```slim
h1 = t('welcome.title')
p = t('welcome.message', name: @user.name)
```

### In Controllers
```ruby
flash[:notice] = I18n.t('messages.success')
```

## Translation Keys Organization
- Use nested structure for logical grouping
- Keep keys descriptive and meaningful
- Use snake_case for keys

```yaml
en:
  users:
    profile:
      title: "User Profile"
      edit: "Edit Profile"
    messages:
      created: "User was successfully created"
      updated: "User was successfully updated"
```

## When Adding New Translations
1. Add the key to ALL language files at the same time
2. Keep the same line number across all files
3. Keep translations on a single line
4. Maintain alphabetical or logical order consistently across all files

## Excluded from Translation Checks
- **activerecord.*** - ActiveRecord translations (attributes, errors, etc.) are excluded from unused key checks
- **devise.*** - Devise gem translations are excluded from unused key checks
- **registrations.unlocks.*** - Devise unlock translations are excluded from unused key checks
- These translations are managed by the gems themselves and should not be flagged as unused
