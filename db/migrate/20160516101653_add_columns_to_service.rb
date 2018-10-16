class AddColumnsToService < ActiveRecord::Migration
  def change
    add_column :services, :location1 ,:string
    add_column :services, :location2 ,:string
    add_column :services, :location3 ,:string
    add_column :services, :location4 ,:string
    add_column :services, :location5 ,:string

  end
end
