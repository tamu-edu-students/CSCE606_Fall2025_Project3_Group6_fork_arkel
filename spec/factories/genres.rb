FactoryBot.define do
  factory :genre do
    sequence(:tmdb_id) { |n| 28 + n }
    name { "Action" }
  end
end
