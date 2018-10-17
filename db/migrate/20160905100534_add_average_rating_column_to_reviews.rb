class AddAverageRatingColumnToReviews < ActiveRecord::Migration
  
  add_column :reviews,:average_rating ,:integer

end
