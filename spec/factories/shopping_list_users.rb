# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_list_user do
    association :shopping_list
    association :user
  end
end
