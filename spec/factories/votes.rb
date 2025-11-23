FactoryBot.define do
  factory :vote do
    user { nil }
    review { nil }
    value { 1 }
  end
end
