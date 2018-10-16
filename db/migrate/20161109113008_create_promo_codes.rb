class CreatePromoCodes < ActiveRecord::Migration
  def change
    create_table :promo_codes do |t|
      t.string :name
      t.string :description
      t.string :promo_code
      t.date :expiration
      t.float :discount_by_percentage


      t.timestamps null: false
    end
  end
end
