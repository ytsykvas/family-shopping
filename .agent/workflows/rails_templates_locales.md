---
description: Rules for Slim templates and I18n localization
---

# Templates & Locales

## Slim Templates

1. **Format**: All templates MUST use `.slim`. NO ERB.
2. **Location**: Place in `app/concepts/feature_name/component/`.
3. **Translations**: Use `t('.key')` for all user-facing text.

## I18n Locales

1. **Single Line**: Keep each translation on a single line.
    - ❌ **Bad**:
      ```yaml
      message: "Long text
        on two lines"
      ```
    - ✅ **Good**:
      ```yaml
      message: "Long text on one line"
      ```
2. **Synchronized Lines**: Multi-language files must have same line count.
3. **No Hardcoding**: Never hardcode strings in templates or controllers.

### Example (uk.yml)
```yaml
uk:
  friends:
    index:
      title: "Мої друзі"
```
