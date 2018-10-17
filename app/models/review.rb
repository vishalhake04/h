class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :service
  belongs_to :stylist,:foreign_key => "stylist_id",:class_name => "User"



def self.calculate_average_rating(professionalism,quality,timing)
return (professionalism.to_i+quality.to_i+timing.to_i)/3
end

end
