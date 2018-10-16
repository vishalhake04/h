class Api::V1::ServiceSerializer < ActiveModel::Serializer
  #include JSONAPI::Serializer
   #cache key: 'service', expires_in: 3.hours

  attributes :id,:amount,:time,:location1,:location2,:location3,:location4,:location5
  has_one :user
  has_one :photo
  has_one :service_sub_category

 def id
   return object.id.to_s if serialization_options[:total_count].blank?
 end


  def amount
    object.amount.to_s
  end

  def service_sub_category

  Api::V1::ServiceSubCategorySerializer.new(object.service_sub_category,:except=>[:amount,:time],root:false)

  end

  def user
      Api::V1::UserSerializer.new(object.user,root:false,:except=>[:city,:state,:zipcode,:address])
  end


  def photo
    object.photo.image.url(:medium) if !object.photo.blank?
  end

end
