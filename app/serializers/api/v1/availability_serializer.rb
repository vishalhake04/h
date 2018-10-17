class Api::V1::AvailabilitySerializer < ActiveModel::Serializer
  #cache key:  'availability', expires_in: 3.hours

  attributes :id, :mon, :tue, :time, :wed, :thu, :fri, :sat, :sun
end
