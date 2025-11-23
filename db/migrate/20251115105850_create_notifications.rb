class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :actor_id
      t.string :notification_type
      t.string :notifiable_type
      t.integer :notifiable_id
      t.boolean :read

      t.timestamps
    end
  end
end
