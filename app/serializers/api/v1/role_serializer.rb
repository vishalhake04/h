class Api::V1::RoleSerializer < ActiveModel::Serializer

  #cache key: 'role', expires_in: 3.hours


  attributes :id, :name

  def id
    object.id.to_s
  end
end
