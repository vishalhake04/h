class GiftCardsController < ApplicationController
 def index
  @alert=params[:alert] if !params[:alert].blank?
 end
 def create
   session[:gift_card_id]=nil
   gift_card=GiftCard.new
   gift_card.message=params[:message]
   gift_card.user_id=params[:user_id]
   gift_card.to_email=params[:email]
   gift_card.amount=params[:amount]
   gift_card.validity=3.months.from_now
   letters = (0..9).to_a + ('a'..'z').to_a + ('A'..'Z').to_a
   gift_card.gift_code="RED-"+letters.sample(5).join+"-"+letters.sample(3).join
   if gift_card.save
     session[:gift_card_id]=gift_card.id
     redirect_to  gift_card_payment_path
    else
     redirect_to  gift_cards_path(:alert=>"amount cant be nil")

    end

 end


end