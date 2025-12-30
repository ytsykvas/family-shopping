# frozen_string_literal: true

class ShoppingList < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :shopping_list_items, dependent: :destroy
  has_many :shopping_list_users, dependent: :destroy
  has_many :members, through: :shopping_list_users, source: :user

  validates :name, presence: true

  def owned_by?(user)
    owner_id == user&.id
  end

  def has_member?(user)
    shopping_list_users.exists?(user_id: user&.id)
  end

  def accessible_by?(user)
    owned_by?(user) || has_member?(user)
  end
end
