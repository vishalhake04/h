class Api::V1::ServiceCategorySerializer < ActiveModel::Serializer

  #cache key: 'service_category', expires_in: 3.hours


  attributes :id, :name
  has_one :photo
  def id
    object.id.to_s
  end
  def photo
    object.photo.image.url(:medium) if !object.photo.blank?
  end
end
