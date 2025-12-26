---
alwaysApply: true
---

# Template Files Rules

## Template Format
- All template files MUST use Slim format with `.slim` extension
- Template file naming: `name.slim` (e.g., `index.slim`, `show.slim`)
- NO ERB templates - only Slim

## Template Location
- All new templates MUST be placed in `app/concepts/` directory structure
- DO NOT use `app/views/` directory for new templates
- Templates are located alongside their component classes in `component/` subdirectories

## Component Structure
Each component follows this pattern:

```
app/concepts/
  feature_name/
    component/
      component_name.rb      # Component class (inherits from Base::Component::Base)
      component_name.slim    # Slim template file
```

### Examples from the project:

**Home feature:**
```
app/concepts/home/component/
  index.rb    # class Home::Component::Index < Base::Component::Base
  index.slim  # Slim template
```

**Shared components:**
```
app/concepts/shared/navbar/component/
  show.rb     # class Shared::Navbar::Component::Show < ViewComponent::Base
  show.slim   # Slim template
```

## Component Class Requirements
- Component classes inherit from `Base::Component::Base` or `ViewComponent::Base`
- Class name matches the file structure: `Feature::Component::TemplateName`
- Include `# frozen_string_literal: true` at the top of Ruby files
- Template file has the same base name as the component class file

## Rendering Components
- Components are rendered using ViewComponent conventions
- Template is automatically discovered based on component class location
