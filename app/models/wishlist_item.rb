class WishlistItem < ApplicationRecord
  belongs_to :user
  belongs_to :booked_by_user, class_name: "User", optional: true

  has_one_attached :image

  enum :status, { pending: 0, booked: 1 }

  CURRENCIES = %w[UAH USD EUR].freeze

  validates :title, presence: true
  validates :currency, inclusion: { in: CURRENCIES }, allow_blank: true

  before_save :normalize_url

  def external_url
    return nil if url.blank?

    if url.match?(%r{\Ahttps?://})
      url
    else
      "https://#{url}"
    end
  end

  private

  def normalize_url
    return if url.blank?
    return if url.match?(%r{\Ahttps?://})

    self.url = "https://#{url}"
  end
end
