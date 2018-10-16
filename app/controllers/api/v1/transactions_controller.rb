class Api::V1::TransactionsController <  Api::V1::BaseController

    include TransactionsHelper,HomeHelper
    before_action :authenticate_user!,:except => [:calculate_tax]
    before_action :check_booking, :only => [:create]
    before_action :auth_to_create!, :only => [:create,:new]

    def new
      client_token = Transaction.generate_client_token(current_user)
      render(json: { client_token:client_token }.to_json)

      # @transaction=Transaction.new
    end

    def calculate_tax

     amount=params[:service_amount]
     total_amount=(amount.to_i-((8.875/100)*amount.to_i)).round
     render(json: { service_amount:amount,taxable_amount:((8.875/100)*amount.to_i).round,total_amount:total_amount }.to_json)

    end

    def create

      transaction_params=params[:transaction]
      booking=Booking.find(transaction_params[:booking_id])
      pay_half_trans_and_full_gift=transaction_params[:pay_half_trans_and_full_gift].blank? ? false : true
      amount_plain_trans=transaction_params[:amount]
      gift_deducted_amount=transaction_params[:gift_deducted_amount]
      amount=gift_deducted_amount.blank? ?  amount_plain_trans : gift_deducted_amount
      @result=Transaction.transaction_sale(transaction_params,amount,false)
      if @result.success?

        transaction=Transaction.new(booking_id:booking.id,braintree_transaction_id:@result.transaction.id,stylist_id:booking.stylist_id,amount_paid:amount,transaction_status:@result.transaction.status,pay_via:"transaction")
        transaction.save
        booking.update(:status => Booking::PENDING)
        create_message_booking(params[:message], booking) if !params[:message].blank?

        Transaction.booking_success_with_successfull_transaction_message(current_user)

        RedderaWorker.perform_at(10.minute.from_now, booking.id, transaction.braintree_transaction_id) if booking.dates == Date.today
        RedderaWorker.perform_at(1.hour.from_now, booking.id, transaction.braintree_transaction_id) if booking.dates > Date.today
        current_user.update(braintree_customer_id: @result.transaction.customer_details.id) #unless current_user.has_payment_info?

        if pay_half_trans_and_full_gift == true
          gift_card=GiftCard.find(transaction_params[:gift_card_id])
          discounted_amount=transaction_params[:discounted_amount]
          update_gift_card(gift_card)
          transaction=Transaction.new(booking_id:booking.id,gift_card_id:gift_card.id,stylist_id:booking.stylist_id,pay_via:"pay_half_trans_and_gift",amount_paid:discounted_amount)
          transaction.save
        end
        render(json: { success: true, transaction_id:transaction.id,message: "Transaction successfully created." }.to_json)

      else
        #flash[:alert] = "Something went wrong while processing your transaction. Please try again!"
        gon.client_token =Transaction.generate_client_token(current_user)
        render(json: { success: false, message:@result.errors.map{|error| error.message}.join(" ")}.to_json)


      end



    end

    def gift_card_payment_create
      transaction=Transaction.new
      transaction.gift_card_id=params[:gift_card_id]
      gift_card= GiftCard.find(params[:gift_card_id])
      @result=Transaction.transaction_sale(params,params[:amount],true)
      if @result.success?
        transaction.braintree_transaction_id=@result.transaction.id
        transaction.transaction_status=@result.transaction.status
        transaction.save
        UserMailer.gift_card(gift_card).deliver
        render(json:{ success: true, message: "Transaction successfully created." }.to_json)
      else
        gon.client_token =Transaction.generate_client_token(current_user)
        render(json:{ success: false, message: @result.errors.map{|error| error.message}.join(" ")}.to_json)
      end
    end

    def pay_via_gift_card
     begin
      booking=Booking.find(params[:booking_id])
      Transaction.pay_via_gift_card_micro(params,booking)
      create_message_booking(params[:message], booking) if !params[:message].blank?
      render(json:{ success: true, message: "Transaction successfully created." }.to_json)
     rescue ActiveRecord::RecordNotFound
      not_found
    end
    end


    def discounted_price
      begin

        @service_amount=params[:service_amount]
        @total_amount=Transaction.total_amount_deducted_from_tax(@service_amount)
        @taxable_amount= format('%02d', ((8.875/100)*@service_amount.to_i).round)
        coupon=params[:coupon_code]
        raise Exception, "Enter the code" if  coupon.blank?
        @gift_card=GiftCard.find_by_gift_code(coupon)
        raise Exception, "Please enter a valid code"  if @gift_card.blank? || check_coupon_validity(@gift_card)
        gift_amount=Transaction.get_gift_amount(@gift_card)
        discounted_price_calculation(@total_amount,gift_amount)
        render(json:{ service_amount:@service_amount,total_amount:@total_amount,taxable_amount:@taxable_amount,json:@json,gift_card_id:@gift_card.id}.to_json)

          #render_transaction_bill_page

      rescue Exception => exc
        @message=exc.message
        render(json:{ success: false, message:@message }.to_json)


      end

    end

    def index
      @notify =params[:notify]

      if current_user.isStylist?
        #@payment_info= !PayoutInfo.find_by_user_id(current_user.id).blank? ? PayoutInfo.find_by_user_id(current_user.id) : PayoutInfo.new

        transactions=Transaction.transaction_history


        # transactions=Transaction.where(:stylist_id => current_user.id)
       getTransactionListJson(transactions)
      else
       transactions=Transaction.transaction_history
        # bookings=Booking.where(:user_id=>current_user.id)
        # transactions=bookings.map{|booking|booking.transactions.first}.reject{|n| n==nil}

       render(json:transactions,each_serializer: Api::V1::GroupedSomeModelSerializer)


      # getTransactionListJson(transactions)
      end
    end

    protected


    def getTransactionListJson(transactions)
      render(
          json:
              transactions,
              each_serializer: Api::V1::TransactionSerializer,


      )
    end

    def check_booking
      begin
        @booking = Booking.find(params[:transaction][:booking_id])
      rescue ActiveRecord::RecordNotFound
        not_found
      end
    end

    def auth_to_create!
      return (current_user.isClient?) ? true : unauthenticated!
    end

    def transaction_params
        params[:transaction].permit(:braintree_transaction_id ,:booking_id)
    end
end
