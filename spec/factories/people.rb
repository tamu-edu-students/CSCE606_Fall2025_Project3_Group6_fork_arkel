FactoryBot.define do
  factory :person do
    sequence(:tmdb_id) { |n| n }
    sequence(:name) { |n| "Person #{n}" }
    profile_path { "MyString" }
  end
end
