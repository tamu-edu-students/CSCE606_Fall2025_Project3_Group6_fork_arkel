FactoryBot.define do
  factory :user_stat do
    user { nil }
    total_movies { 1 }
    total_hours { 1 }
    total_reviews { 1 }
    total_rewatches { 1 }
    top_genres_json { "" }
    top_actors_json { "" }
    top_directors_json { "" }
    heatmap_json { "" }
  end
end
