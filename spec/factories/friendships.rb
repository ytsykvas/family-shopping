# frozen_string_literal: true

FactoryBot.define do
  factory :friendship do
    association :requester, factory: :user
    association :accepter, factory: :user
    status { :pending }

    trait :accepted do
      status { :accepted }
    end

    trait :blocked do
      status { :blocked }
    end
  end
end
