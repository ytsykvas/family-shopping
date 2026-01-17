# frozen_string_literal: true

class ShoppingListInvitation < ApplicationRecord
  enum :status, { pending: 0, accepted: 1, rejected: 2 }

  belongs_to :shopping_list
  belongs_to :inviter, class_name: "User"
  belongs_to :invitee, class_name: "User"

  validates :invitee_id, uniqueness: { scope: :shopping_list_id, message: "has already been invited to this list" }

  scope :pending, -> { where(status: :pending) }
end
