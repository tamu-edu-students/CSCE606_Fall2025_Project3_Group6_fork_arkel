FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user_#{n}" }
    password { "Password123!" }
    password_confirmation { "Password123!" }
    confirmed_at { Time.current }
  end
end
