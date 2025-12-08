FactoryBot.define do
  factory :user_achievement do
    association :user
    association :achievement
    earned_at { "2025-11-15 04:58:56" }
  end
end
