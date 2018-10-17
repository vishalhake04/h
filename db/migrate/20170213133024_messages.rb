class Messages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :message
      t.timestamps null: false
    end
    add_column :messages,:stylist_id,:integer
    add_reference :messages, :user, index: true, foreign_key: true
    add_index :messages, :stylist_id
  end
end
