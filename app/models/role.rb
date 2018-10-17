class Role < ActiveRecord::Base
  has_many  :users

  ADMIN = 1
  CLIENT = 2
  STYLIST = 3

end
