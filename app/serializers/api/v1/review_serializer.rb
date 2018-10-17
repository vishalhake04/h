class Api::V1::ReviewSerializer < ActiveModel::Serializer

  #cache key: 'review', expires_in: 3.hours


  attributes :id, :comments
  has_one :stylist
  has_one :user
end
