# frozen_string_literal: true

class ShoppingListUser < ApplicationRecord
  belongs_to :shopping_list
  belongs_to :user

  validates :user_id, uniqueness: { scope: :shopping_list_id }
end
