class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.text :body
      t.integer :rating
      t.boolean :reported
      t.integer :cached_score

      t.timestamps
    end
  end
end
