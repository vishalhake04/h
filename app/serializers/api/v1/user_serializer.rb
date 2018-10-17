class Api::V1::UserSerializer < ActiveModel::Serializer

  #cache key: 'user', expires_in: 3.hours


  attributes :id, :email, :first_name,:last_name,:gender,:phone,:address,:city,:state,:zipcode,:address2
 # attributes :reviews
  has_one :role
  has_one :photo
  has_one :favourite
  has_one :review_count
  has_one :portfolio_image
  #has_many :recommendations
  #has_one :review
  #has_many :reviews

  def id
   object.id.to_s
  end

  def review_count

   reviews=Review.where(:stylist_id=>object.id).count.to_s  if object.role_id==Role::STYLIST
  end

  def portfolio_image
    object.previous_works.first
  end

  def favourite
    favourites=FavouriteStylist.where(:stylist_id=>object.id).count.to_s  if object.role_id==Role::STYLIST
  end

  def role
    Api::V1::RoleSerializer.new(object.role,root:false)
  end

  def photo
    object.photo.image.url if !object.photo.blank?
  end

end
