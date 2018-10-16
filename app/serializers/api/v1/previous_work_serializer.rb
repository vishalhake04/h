class Api::V1::PreviousWorkSerializer < ActiveModel::Serializer

  #cache key: 'previous_work', expires_in: 3.hours

  attributes :id,:legend,:description
  has_one :photo

  def id
    object.id.to_s
  end

  def photo
    object.photo.image.url(:medium) if !object.photo.blank?
  end

end
