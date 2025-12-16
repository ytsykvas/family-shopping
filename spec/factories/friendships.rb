# frozen_string_literal: true

FactoryBot.define do
  factory :friendship do
    association :requester, factory: :user
    association :accepter, factory: :user
    status { :pending }
    message { nil }

    trait :accepted do
      status { :accepted }
    end

    trait :blocked do
      status { :blocked }
    end

    trait :with_message do
      message { Faker::Lorem.sentence(word_count: 10) }
    end
  end
end
