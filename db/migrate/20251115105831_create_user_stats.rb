class CreateUserStats < ActiveRecord::Migration[8.0]
  def change
    create_table :user_stats do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :total_movies
      t.integer :total_hours
      t.integer :total_reviews
      t.integer :total_rewatches
      t.json :top_genres_json
      t.json :top_actors_json
      t.json :top_directors_json
      t.json :heatmap_json

      t.timestamps
    end
  end
end
