FactoryBot.define do
  factory :recipe do
    association :user
    name { "Pancakes" }
    description { Faker::Lorem.paragraph }
  end
end
