class AddStylistColumnsToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions,:stylist_id,:integer
    add_index :transactions, :stylist_id
  end
end
