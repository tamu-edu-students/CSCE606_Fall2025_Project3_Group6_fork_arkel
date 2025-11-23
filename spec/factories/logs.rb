FactoryBot.define do
  factory :log do
    user { nil }
    movie { nil }
    watched_on { "2025-11-15" }
    rating { 1 }
    review_text { "MyText" }
    rewatch { false }
  end
end
