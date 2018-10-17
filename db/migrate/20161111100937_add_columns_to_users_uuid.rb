class AddColumnsToUsersUuid < ActiveRecord::Migration
  def change
    add_column :users, :apple_uuid ,:string
  end
end
