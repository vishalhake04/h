class CreatePayoutInfos < ActiveRecord::Migration
  def change
    create_table :payout_infos do |t|
      t.string :legal_name
      t.string :business_name
      t.string :tax_id
      t.string :dob
      t.string :ssn
      t.integer :account_number
      t.integer :routing_number
      t.string :street_address
      t.string :city
      t.string :state
      t.integer :zipcode
      t.timestamps null: false
    end
  end
end
