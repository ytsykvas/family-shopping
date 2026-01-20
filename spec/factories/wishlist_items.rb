FactoryBot.define do
  factory :wishlist_item do
    association :user
    title { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }
    url { Faker::Internet.url }
    price { Faker::Commerce.price(range: 1.0..1000.0) }
    currency { WishlistItem::CURRENCIES.sample }
    status { "pending" }

    trait :booked do
      status { "booked" }
      association :booked_by_user, factory: :user
    end

    trait :with_image do
      after(:build) do |item|
        item.image.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")),
          filename: "test_image.jpg",
          content_type: "image/jpeg"
        )
      end
    end
  end
end
