class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|

      t.string  :name
      t.string  :description
      t.integer  :amount
      t.decimal :time
      t.timestamps null: false
      t.string :location
    end
  end
end
