class Api::V1::PromoCodeSerializer < ActiveModel::Serializer

  #cache key: 'promo_code', expires_in: 3.hours


  attributes :id,:name,:description,:expiration,:discount_by_percentage

end