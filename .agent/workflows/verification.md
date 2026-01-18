---
description: Verification checks to run after completing a feature implementation
---

# Post-Implementation Verification

After completing any feature implementation, run the following verification commands to ensure code quality:

// turbo-all

## 1. Zeitwerk Check
Verify autoloading and eager loading are configured correctly:
```bash
bin/rails zeitwerk:check
```

## 2. RSpec Tests
Run the full test suite to ensure no regressions:
```bash
bundle exec rspec
```

## 3. RuboCop
Check for code style and linting issues:
```bash
rubocop
```

## 4. I18n Health Check
Verify translations are complete and unused keys are cleaned up:
```bash
bundle exec i18n-tasks health
```

## Expected Results

All commands should pass without errors:
- `zeitwerk:check`: "All files checked and no issues found"
- `rspec`: "0 failures"
- `rubocop`: "no offenses detected"
- `i18n-tasks health`: All checks green (no missing/unused translations)

If any command fails, fix the issues before considering the feature complete.
