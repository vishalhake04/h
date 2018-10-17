class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.date :dates
      t.string :slots
      t.boolean :is_confirmed,:default=>false
      t.boolean :is_deleted,:default=>false
      t.string :status,:default => ""
      t.timestamps null: false
    end

  end
end
