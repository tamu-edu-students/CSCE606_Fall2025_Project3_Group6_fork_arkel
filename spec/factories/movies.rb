FactoryBot.define do
  factory :movie do
    sequence(:tmdb_id) { |n| n }
    title { "MyString" }
    overview { "MyText" }
    poster_path { "MyString" }
    release_date { Date.new(2000, 1, 1) }
    runtime { 120 }
    popularity { 1.5 }
    cached_at { Time.current }
  end
end
