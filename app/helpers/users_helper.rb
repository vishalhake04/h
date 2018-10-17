module UsersHelper
  include HomeHelper
  def devise_mapping
    Devise.mappings[:user]
  end

  def resource_name
    devise_mapping.name
  end

  def resource_class
    devise_mapping.to
  end

  def getuserAvaliability(user)
    availabilities=Booking.getAvaliabilities(user)

  end

  def   getPreviousWorksOfUser(user)
    user.previous_works.where(:is_additional=>false)
  end

  def get_updated_availability(user)

    user.update_availabilities.blank? ? [] : user.update_availabilities.first.date_time.to_json

  end

   def check_booking_user_with_stylist(user)

   #  .include?(true) ?  false : true

     stylists=user.bookings.map(&:stylist).uniq.reject { |n| n==nil}.collect{|user| user.id==params[:id].to_i }.include?(true) ?  false : true

   end

  def getFavouriteCount(stylist)

   return FavouriteStylist.where(:stylist_id=>stylist.id,:unfavourite => false).count

  end

  def getuserBooking(user)
    Booking.getBookings(user)
  end

  def check_if_favourite(current_user,stylist)

   if current_user.blank?
     return true
   else

     favourite_stylist=current_user.favourite_stylists.where(:stylist_id=>stylist.id)

     if favourite_stylist.blank? || favourite_stylist.first.unfavourite == true || favourite_stylist.first.user.id != current_user.id
       return false
     else if favourite_stylist.first.user.id == current_user.id ||favourite_stylist.first.unfavourite==false
            return true
          end
     end
   end

  end
=begin
  def get_client_token

    return  generate_client_token
  end

  def generate_client_token
    if current_user.has_payment_info?
      Braintree::ClientToken.generate(customer_id: current_user.braintree_customer_id)
    else

      Braintree::ClientToken.generate
    end
  end
=end

  def has_past_bookings(user)
    past= user.bookings.where(:status=>Booking::PAST ,:is_confirmed=>true,:is_deleted=>false)
    if past.blank?
      return false
    else
      return true
    end
  end
end
