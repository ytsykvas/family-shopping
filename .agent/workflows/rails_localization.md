---
description: Rules for Internationalization (I18n) and Localization
---

# Internationalization (I18n) Rules

1.  **NO HARDCODED STRINGS**: All user-facing text must be extracted to locale files (`config/locales/*.yml`).
2.  **Use `I18n.t`**: Always use `I18n.t('key.path')` to retrieve strings.
3.  **Strictly NO Defaults**: Do not use the `default:` option in `I18n.t` to provide a fallback string in the code. The string MUST exist in the locale files.
    *   **BAD**: `I18n.t('some.key', default: 'Some text')`
    *   **GOOD**: `I18n.t('some.key')` (and ensure 'some.key' exists in `en.yml` and `uk.yml`)
4.  **Dual Locales**: When adding a new string, you MUST add it to BOTH `config/locales/en.yml` and `config/locales/uk.yml`.
5.  **Structure**: Nest keys logically under the feature or component name (e.g., `shopping_lists.index.title`, `shopping_lists.form.submit`).
