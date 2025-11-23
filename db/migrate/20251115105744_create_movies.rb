class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    create_table :movies do |t|
      t.integer :tmdb_id
      t.string :title
      t.text :overview
      t.string :poster_path
      t.date :release_date
      t.integer :runtime
      t.float :popularity
      t.datetime :cached_at

      t.timestamps
    end
    add_index :movies, :tmdb_id
  end
end
