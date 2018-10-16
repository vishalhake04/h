class AddReferenceToTransaction < ActiveRecord::Migration
  def change
    add_reference :transactions, :booking, index: true, foreign_key: true
  end
end
