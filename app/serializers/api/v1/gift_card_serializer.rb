class Api::V1::GiftCardSerializer < ActiveModel::Serializer
  attributes :id,:message,:user_id,:to_email,:amount,:gift_code,:validity
end
