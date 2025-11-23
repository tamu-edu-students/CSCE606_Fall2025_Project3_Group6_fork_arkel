class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.integer :tmdb_id
      t.string :name
      t.string :profile_path

      t.timestamps
    end
  end
end
