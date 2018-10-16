class ServiceCategory < ActiveRecord::Base
  has_many :service_sub_categories,:dependent => :destroy
 # has_one :beauty_service, class_name: "Service",:dependent => :destroy
   has_many :services,:dependent => :destroy
  has_one :photo,:as=>:imageable


end
