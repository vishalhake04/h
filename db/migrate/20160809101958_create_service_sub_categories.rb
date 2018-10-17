class CreateServiceSubCategories < ActiveRecord::Migration
  def change
    create_table :service_sub_categories do |t|
        t.string :name
        t.string :description
        t.float :price
        t.timestamps null: false
    end

    add_reference :service_sub_categories, :service_category, index: true, foreign_key: true

  end
end
