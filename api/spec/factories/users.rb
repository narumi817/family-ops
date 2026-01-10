FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    name { "テストユーザー" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_oauth do
      email { nil }
      password_digest { nil }
      provider { "google" }
      uid { |n| "123456789#{n}" }
    end
  end
end

