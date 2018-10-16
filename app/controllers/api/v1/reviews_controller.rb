class Api::V1::ReviewsController < Api::V1::BaseController
 before_action :authenticate_user!, :only => [:create,:auth_to_create!]
 before_action :auth_to_create! ,:only => [:create]

  def reviewsByUserId

    begin
      reviews = Review.where(:stylist_id => params[:user_id])
      getReviewsListJson(reviews)
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end


  def create
     review=current_user.reviews.new(review_params)
     review.average_rating=Review.calculate_average_rating( review.professionalism,review.quality,review.timing)
     review.save
     render(json: { success: true, message:"Review posted" }.to_json)

  end

  private

  def getReviewsListJson(reviews)

         render(json:reviews,
                   each_serializer: Api::V1::ReviewSerializer
         )
  end
   def getServiceJson(review)
      render(json: Api::V1::ReviewSerializer.new(review).to_json)
    end

  def review_params
    params.require(:reviews).permit(:user_id,:stylist_id,:comments,:quality,:professionalism,:timing)
  end

  def auth_to_create!
      return current_user.isClient? ? true : unauthenticated!
  end

end
