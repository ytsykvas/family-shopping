module Entities
  class WishlistItem < Grape::Entity
    expose :id
    expose :title
    expose :description
    expose :url
    expose :price
    expose :currency
    expose :status
    expose :image_url do |instance|
      instance.image.url if instance.image.attached?
    end
    expose :user_id
    expose :booked_by_user_id
    expose :created_at
    expose :updated_at
  end
end
