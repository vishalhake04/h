class AddIsDeleteColumnToServicesAndUsers < ActiveRecord::Migration
  def change
    add_column :users,:is_deleted,:boolean,:default => false
    add_column :services,:is_deleted,:boolean,:default => false

  end
end
