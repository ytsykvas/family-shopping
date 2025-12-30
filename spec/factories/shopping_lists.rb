# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_list do
    name { Faker::Commerce.department }
    association :owner, factory: :user

    trait :with_members do
      transient do
        members_count { 2 }
      end

      after(:create) do |shopping_list, evaluator|
        create_list(:shopping_list_user, evaluator.members_count, shopping_list: shopping_list)
      end
    end
  end
end
