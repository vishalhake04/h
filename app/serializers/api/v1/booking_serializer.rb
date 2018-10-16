class Api::V1::BookingSerializer < ActiveModel::Serializer

  #cache key: 'booking', expires_in: 3.hours


  attributes :id,:dates,:slots,:status,:total_cost,:total_time,:services
  has_one :user
  has_one :stylist


  def total_cost
    object.total_amount
  end



  def services
    service_ids=object.multiple_services
    services=service_ids.map{|id| Service.exists?(id:id) ? Service.find(id) :nil}
    ActiveModel::ArraySerializer.new(services, each_serializer: Api::V1::ServiceSerializer)
  end
end
