FactoryBot.define do
  factory :log do
    association :user
    association :movie
    watched_on { "2025-11-15" }
    rating { 1 }
    review_text { "MyText" }
    rewatch { false }
  end
end
