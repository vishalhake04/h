class Api::V1::FavouriteStylistSerializer < ActiveModel::Serializer

  #cache key: 'favourite_stylist', expires_in: 3.hours


  attributes :id,:unfavourite
  has_one :user
  has_one :stylist
end
