# frozen_string_literal: true

FactoryBot.define do
  factory :shopping_list_invitation do
    shopping_list
    association :inviter, factory: :user
    association :invitee, factory: :user
    status { :pending }

    trait :accepted do
      status { :accepted }
    end

    trait :rejected do
      status { :rejected }
    end
  end
end
