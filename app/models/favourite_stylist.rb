class FavouriteStylist < ActiveRecord::Base
  belongs_to :user
  belongs_to :stylist ,class_name:'User',:foreign_key => "stylist_id"
  #validates :user_id, :presence => true, :uniqueness => true
  validates_uniqueness_of :user_id, :scope => :stylist_id
end
