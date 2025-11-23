class CreateEmailPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :email_preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.boolean :new_follower
      t.boolean :review_votes
      t.boolean :followed_activity

      t.timestamps
    end
  end
end
