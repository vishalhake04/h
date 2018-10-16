class AddAdditionalportfolioToPhotos < ActiveRecord::Migration
  def change
    add_column :previous_works,:is_additional,:boolean ,:default=>false

  end
end
