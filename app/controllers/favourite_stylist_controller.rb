class FavouriteStylistController < ApplicationController
  skip_after_filter :intercom_rails_auto_include
  skip_before_action :verify_authenticity_token


  def index
    @favourite_stylists=current_user.favourite_stylists.where(:unfavourite=>false)

  end


  def create_favourite_list


    if !current_user.blank?
    favourite_list=FavouriteStylist.new
    favourite_list.stylist_id=params[:favourite_list][:stylist_id]
    favourite_list.user_id= params[:favourite_list][:user_id]
    favourite_list.save
    @message="Stylist favourited"
    if favourite_list.save== false
      favourite_stylist=current_user.favourite_stylists.where(:stylist_id=>params[:favourite_list][:stylist_id])
      favourite_stylist.first.update(:unfavourite=>false)
    end
    @user=User.find(params[:favourite_list][:stylist_id])
    respond_to do|format|
      format.js{render :file=> 'users/favourite.js.erb'}

    end
      end
  end

  def unfavourite_list

    if !current_user.blank?

      favourite_stylist=current_user.favourite_stylists.where(:stylist_id=>params[:favourite_list][:stylist_id])
      favourite_stylist.first.update(:unfavourite=>true)
    @user=User.find(params[:favourite_list][:stylist_id])
    @message="Stylist Unfavourited"
    respond_to do|format|
      format.js{render :file=> 'users/favourite.js.erb'}

    end
    end
  end









end
