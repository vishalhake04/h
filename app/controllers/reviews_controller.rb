class ReviewsController < ApplicationController
  skip_after_filter :intercom_rails_auto_include
  before_action :authenticate_user!

  def index

    @reviews=Review.select{|review| review.stylist_id == current_user.id} if current_user.isStylist?
  end

  def new
  @review=current_user.reviews.new if  current_user.isClient?
  end


  def create
     if current_user.isClient?
       review=current_user.reviews.new(review_params)
       review.average_rating=Review.calculate_average_rating( review.professionalism,review.quality,review.timing)
       review.save
       redirect_to stylist_path(review.stylist.id,review.stylist.first_name)
     end
  end


  private

  def review_params
    params.require(:reviews).permit(:user_id,:stylist_id,:comments,:quality,:professionalism,:timing)
  end



end
