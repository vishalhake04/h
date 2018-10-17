class CreateUpdateAvailabilities < ActiveRecord::Migration
  def change
    create_table :update_availabilities do |t|
      t.date :date
      t.boolean :is_not_available,:default=>false
      t.timestamps null: false
    end
    add_reference :update_availabilities,:user, index: true, foreign_key: true

  end
end
