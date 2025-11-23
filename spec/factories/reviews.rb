FactoryBot.define do
  factory :review do
    user { nil }
    movie { nil }
    body { "MyText" }
    rating { 1 }
    reported { false }
    cached_score { 1 }
  end
end
