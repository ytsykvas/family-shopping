FactoryBot.define do
  factory :recipe do
    association :user
    name { "Pancakes" }
  end
end
