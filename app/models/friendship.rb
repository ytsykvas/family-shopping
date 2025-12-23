# frozen_string_literal: true

class Friendship < ApplicationRecord
  enum :status, { pending: 0, accepted: 1, blocked: 2 }

  belongs_to :requester, class_name: "User"
  belongs_to :accepter,  class_name: "User"

  validates :requester_id, presence: true
  validates :accepter_id, presence: true
  validates :accepter_id, uniqueness: { scope: :requester_id }

  scope :pending, -> { where(status: :pending) }
  scope :accepted, -> { where(status: :accepted) }
  scope :blocked, -> { where(status: :blocked) }

  scope :between_users, ->(user1, user2) do
    where(
      "(requester_id = :user1 AND accepter_id = :user2) OR (requester_id = :user2 AND accepter_id = :user1)",
      user1: user1.id, user2: user2.id
    )
  end
end
