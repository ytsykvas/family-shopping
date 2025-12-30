# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_list_item do
    name { Faker::Commerce.product_name }
    association :shopping_list
    association :added_by, factory: :user
    status { "pending" }

    trait :done do
      status { "done" }
    end

    trait :with_editor do
      association :edited_by, factory: :user
    end
  end
end
