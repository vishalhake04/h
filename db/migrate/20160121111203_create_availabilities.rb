class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.timestamps null: false
      t.string  :time
      t.boolean :mon, default:  false
      t.boolean :tue, default:  false
      t.boolean :wed, default:  false
      t.boolean :thu, default:  false
      t.boolean :fri, default:  false
      t.boolean :sat, default:  false
      t.boolean :sun, default:  false
    end
    add_reference :availabilities, :user, index: true, foreign_key: true
  end
end
