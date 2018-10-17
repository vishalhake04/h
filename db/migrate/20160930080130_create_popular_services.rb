class CreatePopularServices < ActiveRecord::Migration
  def change
    create_table :popular_services do |t|
      t.timestamps null: false
    end
    add_reference :popular_services,:service_sub_category,index: true, foreign_key: true

  end
end
