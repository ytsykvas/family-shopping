# frozen_string_literal: true

class ShoppingListItem < ApplicationRecord
  belongs_to :shopping_list
  belongs_to :added_by, class_name: "User"
  belongs_to :edited_by, class_name: "User", optional: true

  validates :name, presence: true

  enum :status, { pending: "pending", done: "done" }, default: "pending", suffix: true

  delegate :owned_by?, :has_member?, :accessible_by?, to: :shopping_list, prefix: :list
end
