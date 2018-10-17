class GiftCards < ActiveRecord::Migration
  def change
    create_table :gift_cards do |t|
      t.string :gift_code
      t.string :to_email
      t.integer :amount
      t.string :message
      t.integer :remaining_amount
      t.boolean :is_valid ,default:true
      t.date :validity
      t.timestamps null: false
    end
    add_reference :gift_cards, :user, index: true, foreign_key: true
    add_reference :transactions, :gift_card, index: true, foreign_key: true
    add_column :transactions, :pay_via, :string
    add_column :gift_cards,:gift_owner_id,:integer
    add_index :gift_cards, :gift_owner_id
    remove_column :users, :verified_number, :boolean
    add_column :users, :verified_number, :boolean,default: false
    add_column :transactions, :amount_paid, :string


  end
end
