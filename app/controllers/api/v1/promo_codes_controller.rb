class Api::V1::PromoCodesController < Api::V1::BaseController
 def index

  promo_codes=PromoCode.all

  render(
      json:promo_codes,
            each_serializer: Api::V1::PromoCodeSerializer

  )
 end

  def code_validity
    begin
    promo_code=PromoCode.find(params[:id])
    if promo_code.expiration > Date.today
      render(json: { success: true, message: "Code is valid" }.to_json)

    else
      render(json: { success: false, message:"Code is not valid" }.to_json)

    end
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

end
