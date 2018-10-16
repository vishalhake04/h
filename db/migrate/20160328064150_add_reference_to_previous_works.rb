class AddReferenceToPreviousWorks < ActiveRecord::Migration
  def change
    add_reference :previous_works, :user, index: true, foreign_key: true
  end
end
