class CreateRecentlyBookeds < ActiveRecord::Migration
  def change
    create_table :recently_bookeds do |t|

      t.timestamps null: false
    end
    add_reference :recently_bookeds, :user, index: true, foreign_key: true

  end
end
