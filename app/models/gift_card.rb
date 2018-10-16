class GiftCard < ActiveRecord::Base
  has_many :transactions
  belongs_to :user
  belongs_to :gift_owner ,class_name:'User',:foreign_key => "stylist_id"
  validates :amount, :uniqueness => {:scope => [:gift_code]}
  validates :amount, presence: true


end