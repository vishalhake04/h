class AddReferenceToPayOutInfos < ActiveRecord::Migration
  def change
    add_reference :payout_infos, :user, index: true, foreign_key: true
  end
end
