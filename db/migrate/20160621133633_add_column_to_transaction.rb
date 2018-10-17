class AddColumnToTransaction < ActiveRecord::Migration
  def change

    add_column :transactions,:is_deleted,:boolean ,:default=>false

  end
end
