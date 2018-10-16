class Api::V1::FavouriteStylistController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :auth_to_create!,:only=>[:create_favourite_list,:unfavourite_list]

  def index
    if current_user.isClient?
     favourite_stylists=current_user.favourite_stylists.where(:unfavourite=>false).map(&:stylist)
    else
      favourite_stylists=FavouriteStylist.where(:unfavourite=>false,:stylist_id=>current_user.id).map(&:stylist)

    end
    render(
        json:favourite_stylists.reject{|v| v==nil},each_serializer:Api::V1::UserSerializer,:except=>[:city,:state,:zipcode,:address]
    )
  end

  def create_favourite_list
    if !current_user.blank?
      begin
      favourite_list=FavouriteStylist.new
      favourite_list.stylist_id=params[:favourite_list][:stylist_id]
      favourite_list.user_id= current_user.id
      favourite_list.save
      if favourite_list.save== false
        favourite_stylist=current_user.favourite_stylists.where(:stylist_id=>params[:favourite_list][:stylist_id])
        favourite_stylist.first.update(:unfavourite=>false)
      end
      @user=User.find(params[:favourite_list][:stylist_id])
      render(json: { sucess: true, message: "Stylist favourited " }.to_json)
      rescue ActiveRecord::RecordNotFound
        not_found
      end
    end
  end

  def unfavourite_list

    if !current_user.blank?
      begin
      favourite_stylist=current_user.favourite_stylists.where(:stylist_id=>params[:favourite_list][:stylist_id])
      favourite_stylist.first.update(:unfavourite=>true)
      @user=User.find(params[:favourite_list][:stylist_id])
      render(json: { sucess: true, message: "Stylist unfavourited " }.to_json)
      rescue ActiveRecord::RecordNotFound
        not_found
      end
    end
  end

  protected
    def auth_to_create!
      return (current_user.isClient?) ? true : unauthenticated!
    end

end