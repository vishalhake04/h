class PromoCodesController < ApplicationController
  skip_after_filter :intercom_rails_auto_include

  def new
    if user_signed_in? && current_user.isAdmin?
      @promo_code=PromoCode.new
      @message=params[:message] if !params[:message].blank?
      @promo_codes=PromoCode.all
    else
      not_found
    end

  end

  def create

   @promo_code=PromoCode.new(promo_params)
   @promo_code.expiration=Date.parse(params[:expiration])
   @promo_code.save
   redirect_to new_promo_codes_path(:message=>"Promo Code Created")
  end

  def delete

    promo_code=PromoCode.find(params[:id])
    promo_code.delete
   @promo_codes=PromoCode.all
    respond_to do |format|
      format.js { render :file => 'promo_codes/delete.js.erb' }
    end
  end

  def promo_params
    params.require(:promo_code).permit(:name,:description,:promo_code,:expiration,:discount_by_percentage)
  end
end
