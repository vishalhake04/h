class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.string :comments
      t.string :quality
      t.string :professionalism
      t.string :timing
      t.timestamps null: false
    end
  end
end
