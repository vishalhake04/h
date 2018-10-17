class RecentlyBookedsController < ApplicationController
  skip_after_filter :intercom_rails_auto_include


  skip_before_action :verify_authenticity_token

  def new

  if user_signed_in? && current_user.isAdmin?
    @recently_booked=RecentlyBooked.order(:id)
  else
    not_found
  end
  end

  def update

    recently_booked=RecentlyBooked.find(params[:id])
    recently_booked.update(:user_id=>params[:user])
    redirect_to recently_booked_new_path
  end
end