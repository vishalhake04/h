class Api::V1::GiftCardsController <  Api::V1::BaseController
  before_action :authenticate_user!
  def create

    letters = (0..9).to_a + ('a'..'z').to_a + ('A'..'Z').to_a
    code="RED-"+letters.sample(5).join+"-"+letters.sample(3).join
    gift_card=GiftCard.new(message:params[:message],user_id:current_user.id,to_email:params[:email],amount:params[:amount],gift_code:code,validity:3.months.from_now)
    if gift_card.save
      render(json: Api::V1::GiftCardSerializer.new(gift_card).to_json)

    else
      redirect_to  gift_cards_path(:alert=>"amount cant be nil")

    end

  end
end
