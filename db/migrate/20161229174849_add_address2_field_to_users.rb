class AddAddress2FieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :address2 ,:string

  end
end
