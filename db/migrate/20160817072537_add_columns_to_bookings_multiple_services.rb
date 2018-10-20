class AddColumnsToBookingsMultipleServices < ActiveRecord::Migration
  def change
    #add_column :bookings, :multiple_services, :json, array:true, default: []
    add_column :bookings, :total_amount,:integer
    add_column :bookings, :total_time,:integer

  end
end
