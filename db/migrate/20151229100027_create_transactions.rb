class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :braintree_transaction_id
      t.string :transaction_status
      t.timestamps null: false
    end


  end
end
