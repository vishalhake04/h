class AddReferenceToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications,:stylist_id,:integer
    add_reference :notifications, :user, index: true, foreign_key: true
    add_index :notifications, :stylist_id
    add_reference :notifications, :booking, index: true, foreign_key: true

  end

end
