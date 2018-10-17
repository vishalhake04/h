class AddReferenceToBookings < ActiveRecord::Migration
  def change
    add_column :bookings,:stylist_id,:integer
    add_reference :bookings, :service, index: true, foreign_key: true
    add_reference :bookings, :user, index: true, foreign_key: true
    add_index :bookings, :stylist_id
  end
end
