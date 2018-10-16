class TransactionsController < ApplicationController
  include TransactionsHelper
  skip_after_filter :intercom_rails_auto_include
  skip_before_action :verify_authenticity_token,:only=>[:discounted_price]

  before_action :authenticate_user!
  before_action :load_braintree_data, only: [:edit]
  include HomeHelper

  def new
    clear_gift_card_session
    gon.client_token = Transaction.generate_client_token(current_user)
    @booking=Booking.find(session[:booking_id])
    @service_amount=@booking.total_amount
    @user=@booking.user
    @message=params[:message] if !params[:message].blank?
    @total_amount=Transaction.total_amount_deducted_from_tax(@service_amount)
    @taxable_amount= format('%02d', ((8.875/100)*@service_amount.to_i).round)

    # @transaction=Transaction.new
  end

  def edit
    @credit_card = current_user.default_credit_card
    @tr_data = edit_customer_tr_data
  end

  def gift_card_payment
    gon.client_token = Transaction.generate_client_token(current_user)
    @gift_card=GiftCard.find(session[:gift_card_id])

  end

  def gift_card_payment_create

    transaction=Transaction.new
    transaction.gift_card_id=session[:gift_card_id]
    gift_card= GiftCard.find(session[:gift_card_id])
    amount=params[:amount]
    @result=Transaction.transaction_sale(params,params[:amount],true)
    if @result.success?
     transaction.braintree_transaction_id=@result.transaction.id
     transaction.transaction_status=@result.transaction.status
     transaction.save
     UserMailer.gift_card(gift_card).deliver
     redirect_to root_path
   else
     gon.client_token =Transaction.generate_client_token(current_user)
     redirect_to gift_card_payment_path(:message => " There was a problem processing your credit card; please double check your payment information and try again")

   end
  end

  def index
    @notify =params[:notify]
    if current_user.isStylist?
      @payment_info= !PayoutInfo.find_by_user_id(current_user.id).blank? ? PayoutInfo.find_by_user_id(current_user.id) : PayoutInfo.new

      @transactions=Transaction.transaction_history
    else
      @transactions=Transaction.transaction_history
    end
  end

  def discounted_price
    begin
      clear_gift_card_session()

      @service_amount=params[:service_amount]
      @total_amount=Transaction.total_amount_deducted_from_tax(@service_amount)
      @taxable_amount= format('%02d', ((8.875/100)*@service_amount.to_i).round)
      coupon=params[:coupon_code]
      raise Exception, "Enter the code" if  coupon.blank?
      @gift_card=GiftCard.find_by_gift_code(coupon)
      raise Exception, "Please enter a valid code"  if @gift_card.blank? || check_coupon_validity(@gift_card)
      gift_amount=Transaction.get_gift_amount(@gift_card)
      discounted_price_calculation(@total_amount,gift_amount)
      session[:discounted_amount]=@json[:discounted_amount]
      session[:gift_deducted_amount]=@json[:gift_deducted_amount]
      session[:gift_card_id]=@gift_card.id


     render_transaction_bill_page

    rescue Exception => exc
      @message=exc.message
      render_transaction_bill_page


    end

    end


  def pay_via_gift_card

    booking=Booking.find(session[:booking_id])
    Transaction.pay_via_gift_card_micro(params,booking)
    create_message_booking(session[:message], booking) if !session[:message].blank?
    redirect_to root_path

  end

  def destroy

    transaction= Transaction.find(params[:id])
    the_transaction_id=transaction.braintree_transaction_id
    transaction = Braintree::Transaction.find(the_transaction_id)
    transaction_status=transaction.status
    if transaction_status=="settled"
      Transaction.delete_transaction(the_transaction_id, transaction_status)
      redirect_to transactions_path
    else
      redirect_to transactions_path(:notify => "Transaction could not be deleted as we are processing the payment")
    end

  end


  def create_transaction

    @result = Braintree::Transaction.sale(
        amount: "0.01",
        payment_method_nonce: params[:payment_method_nonce])

    redirect_to root_path(:reply => "Congraulations! Your transaction has been successfull!. You will get appointment confirmation shortly.")
  end

  def add_payment_method

    result = Braintree::PaymentMethod.create(
        :customer_id => current_user.braintree_customer_id,
        :payment_method_nonce => params[:payment_method_nonce],
        :options => {
            :verify_card => true
        }
    )

    redirect_to edit_user_path(current_user)
  end

  def create

    booking=Booking.find(session[:booking_id])
    pay_half_trans_and_full_gift=session[:pay_half_trans_and_full_gift].blank? ? false : true
    amount_plain_trans=params[:amount_to_be_payed]
    gift_deducted_amount=session[:gift_deducted_amount]
    amount=gift_deducted_amount.blank? ?  amount_plain_trans : gift_deducted_amount
    @result=Transaction.transaction_sale(params,amount,false)
    if @result.success?

      transaction=Transaction.new(booking_id:booking.id,braintree_transaction_id:@result.transaction.id,stylist_id:booking.stylist_id,amount_paid:amount,transaction_status:@result.transaction.status,pay_via:"transaction")
      transaction.save
      booking.update(:status => Booking::PENDING)
      create_message_booking(session[:message], booking) if !session[:message].blank?

      Transaction.booking_success_with_successfull_transaction_message(current_user)

      RedderaWorker.perform_at(10.minute.from_now, booking.id, transaction.braintree_transaction_id) if booking.dates == Date.today
      RedderaWorker.perform_at(1.hour.from_now, booking.id, transaction.braintree_transaction_id) if booking.dates > Date.today
      current_user.update(braintree_customer_id: @result.transaction.customer_details.id) #unless current_user.has_payment_info?

      if pay_half_trans_and_full_gift == true

        gift_card=GiftCard.find(session[:gift_card_id])
        discounted_amount=session[:discounted_amount]
        update_gift_card(gift_card)
        transaction=Transaction.new(booking_id:booking.id,gift_card_id:gift_card.id,stylist_id:booking.stylist_id,pay_via:"pay_half_trans_and_gift",amount_paid:discounted_amount)
        transaction.save
      end
      redirect_to root_path(:reply => "Congraulations! Your transaction has been successfull!. You will get appointment confirmation shortly.")
    else

      #flash[:alert] = "Something went wrong while processing your transaction. Please try again!"
      gon.client_token =Transaction.generate_client_token(current_user)
      redirect_to new_transaction_path(:message => " There was a problem processing your credit card; please double check your payment information and try again")

    end

  end







  def render_transaction_bill_page
    respond_to do |format|
      format.js { render :file => 'transactions/discount' }
    end
  end

  def clear_gift_card_session
    session[:discounted_amount]=nil
    session[:gift_deducted_amount]=nil
    session[:gift_card_id]=nil
    session[:pay_half_trans_and_full_gift]=nil
  end









end
