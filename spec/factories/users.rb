# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    nickname { Faker::Internet.unique.username(specifier: 3..20) }
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password(min_length: 6, max_length: 20) }
    password_confirmation { password }

    trait :with_long_password do
      password { Faker::Internet.password(min_length: 12, max_length: 30) }
      password_confirmation { password }
    end

    trait :with_short_name do
      name { Faker::Name.first_name }
    end

    trait :with_long_name do
      name { "#{Faker::Name.first_name} #{Faker::Name.middle_name} #{Faker::Name.last_name}" }
    end
  end
end
