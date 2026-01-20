class WishlistItem < ApplicationRecord
  belongs_to :user
  belongs_to :booked_by_user, class_name: "User", optional: true

  has_one_attached :image

  enum :status, { pending: 0, booked: 1 }

  CURRENCIES = %w[UAH USD EUR].freeze

  validates :title, presence: true
  validates :currency, inclusion: { in: CURRENCIES }, allow_blank: true
end
