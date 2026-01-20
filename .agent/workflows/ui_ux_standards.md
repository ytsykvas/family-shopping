---
description: UI/UX Standards and Patterns for frontend components
---

# UI/UX Standards

## Destructive Actions (Delete)

When implementing a "Delete" or other destructive action, **NEVER** use the default browser confirmation dialog (`data: { turbo_confirm: ... }`).

### Implementation Rule
Instead, you must implement a custom **Bootstrap Modal** for confirmation.

1.  **Component Strategy**:
    *   Create a dedicated component for the delete modal (e.g., `Feature::Component::Delete`).
    *   This component should contain the full modal HTML structure.
    *   The modal ID must be unique (e.g., `id="deleteItemModal_#{item.id}"`).

2.  **Placement**:
    *   **Render the modal component at the top level of the collection/list**, commonly alongside the `Edit` component loop.
    *   **DO NOT** render the modal inside individual item cards or rows if those elements have complex CSS (like `transform`, `z-index`, or `position: relative`), as this causes stacking context issues (modals appearing behind backdrops or flickering).

3.  **Triggering**:
    *   The "Delete" button in the UI should simply toggle the modal:
        ```slim
        button.btn.btn-danger type="button" data-bs-toggle="modal" data-bs-target="#deleteItemModal_#{item.id}"
          i.bi.bi-trash
        ```

4.  **Confirm Action**:
    *   Inside the modal footer, use `button_to` with `method: :delete` for the actual destruction.
    *   DO NOT use `turbo_confirm` on this final button.

### Example

**The Modal Component (`delete.slim`)**:
```slim
.modal.fade id="deleteItemModal_#{@item.id}" tabindex="-1" ...
  .modal-dialog
    .modal-content
      .modal-header
        h5 = I18n.t('items.delete_confirm_title')
      .modal-body
        = I18n.t('items.delete_confirm_body')
      .modal-footer
        = helpers.button_to I18n.t('delete'), helpers.item_path(@item), method: :delete, class: "btn btn-danger"
```

**The Index Page (`index.slim`)**:
```slim
- @items.each do |item|
   = render Feature::Component::ItemCard.new(item: item)

/ Render modals outside the card loop to prevent CSS issues
- @items.each do |item|
   = render Feature::Component::Delete.new(item: item)
```
