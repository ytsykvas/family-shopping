FactoryBot.define do
  factory :ingredient do
    association :recipe
    content { "Eggs 2pcs" }
  end
end
