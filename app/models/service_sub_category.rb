class ServiceSubCategory < ActiveRecord::Base
  belongs_to :service_category
  has_one :photo, :as=>:imageable
  #has_one :beauty_service, class_name: "Service",:dependent => :destroy
  has_many :services,:dependent => :destroy
 has_many :popular_services,:dependent => :destroy

end
