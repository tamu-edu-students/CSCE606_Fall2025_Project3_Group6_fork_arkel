class CreateLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.date :watched_on
      t.integer :rating
      t.text :review_text
      t.boolean :rewatch

      t.timestamps
    end
  end
end
