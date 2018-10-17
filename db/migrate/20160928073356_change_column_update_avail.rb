class ChangeColumnUpdateAvail < ActiveRecord::Migration
  def change
    # remove_column :update_availabilities, :date, :date
    # add_column :update_availabilities, :date_time,:json,array:true, default: []
  end



  # def change
  #   change_column(:update_availabilities, :date, :text,array:true, default: [])
  # end


end
