class CreatePreviousWorks < ActiveRecord::Migration
  def change
    create_table :previous_works do |t|
      t.string  :description
      t.string  :legend
      t.timestamps null: false
    end
  end
end
