class CreateFeaturedProfessionals < ActiveRecord::Migration
  def change
    create_table :featured_professionals do |t|

      t.timestamps null: false
    end
    add_reference :featured_professionals, :user, index: true, foreign_key: true

  end

end
