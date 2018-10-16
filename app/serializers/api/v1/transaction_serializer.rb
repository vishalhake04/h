class Api::V1::TransactionSerializer < ActiveModel::Serializer

  #cache key: 'transaction', expires_in: 3.hours
  attributes :id,:amount_paid,:pay_via
  has_one :booking
end
