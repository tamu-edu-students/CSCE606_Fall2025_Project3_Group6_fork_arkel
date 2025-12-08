FactoryBot.define do
  factory :watchlist_item do
    association :watchlist
    association :movie
  end
end
