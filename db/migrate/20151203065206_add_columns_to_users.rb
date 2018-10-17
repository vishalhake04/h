class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :name, :string
    add_column :users, :phone, :string
    add_column :users, :address, :string
    add_column :users, :brand, :string
    add_column :users, :braintree_customer_id, :string
    add_column :users, :description,:text
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
    add_column :users, :verified_number, :boolean
    add_column :users, :pin, :string
    add_column :users, :zipcode ,:string
    add_column :users, :stylist_type ,:string
    add_column :users, :authentication_token, :string
    add_column :users,:marked,:string
    add_index :users, :authentication_token,   unique: true
  end
end
