class CreateFavouriteStylists < ActiveRecord::Migration
  def change
    create_table :favourite_stylists do |t|

      t.timestamps null: false
    end
    add_column :favourite_stylists,:stylist_id,:integer
    add_index :favourite_stylists, :stylist_id
    add_reference :favourite_stylists, :user, index: true, foreign_key: true
    add_column :favourite_stylists,:unfavourite,:boolean ,:default=>false

  end


end
