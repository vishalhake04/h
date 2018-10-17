class AddReferenceToReviews < ActiveRecord::Migration
  def change
    add_column :reviews,:stylist_id,:integer
    add_index :reviews, :stylist_id
    add_reference :reviews, :user, index: true, foreign_key: true
    add_reference :reviews, :service, index: true, foreign_key: true
  end
end
