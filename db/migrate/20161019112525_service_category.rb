class ServiceCategory < ActiveRecord::Migration
  def change
    add_column :service_categories,:is_deleted,:boolean,:default => false

  end
end
