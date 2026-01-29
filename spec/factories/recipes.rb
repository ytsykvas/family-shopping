FactoryBot.define do
  factory :recipe do
    association :user
    name { "Pancakes" }
    description { Faker::Lorem.paragraph }

    trait :with_ingredients do
      after(:create) do |recipe|
        create_list(:ingredient, 3, recipe: recipe)
      end
    end
  end
end
