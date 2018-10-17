class Api::V1::ServiceSubCategorySerializer < ActiveModel::Serializer

  #cache key: 'service_sub_category', expires_in: 3.hours


  attributes :id, :name ,:description,:amount,:time
  has_one :service_category
  has_one :photo

  def amount
    !scope[:amount].blank? ?  scope[:amount].to_s : " "
  end

  def time
    !scope[:time].blank? ?  scope[:time].to_s : " "
  end

  def id
    object.id.to_s
  end

  def photo
    object.photo.image.url(:medium) if !object.photo.blank?
  end
end
