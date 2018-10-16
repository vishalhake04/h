class Transaction < ActiveRecord::Base
  require 'date'
  TRANSACTION_STATUS_VOID=['settlement_confirmed','settlement_declined','settlement_pending','submitted_for_settlement']
  TRANSACTION_STATUS_REFUND=["settling","settled"]
  belongs_to :booking
  belongs_to :stylist ,class_name:'User',:foreign_key => "stylist_id"
  belongs_to :gift_card

  def generate_client_token

    if current_user.has_payment_info?
      Braintree::ClientToken.generate(customer_id: current_user.braintree_customer_id)
    else
      Braintree::ClientToken.generate
    end
  end

 def self.my_earnings(bookings,earnings_till_date)

  tot_expected_earnings=tot_expected_earnings(bookings)

  total_earnings= (earnings_till_date.blank? ? 0 : earnings_till_date.to_i) +  (tot_expected_earnings.blank? ? 0:tot_expected_earnings.to_i)
   return my_earnings={:month=>Date.today.strftime("%B"),:tot_earnings_till_date=>earnings_till_date,:tot_expected_earnings=>tot_expected_earnings,:total_earnings=>total_earnings}


 end

def self.total_earnings_till_date(booking)

  booking_till_date=booking.select{|booking| booking.dates.between?(Date.today.beginning_of_month,Date.yesterday) && booking.status==Booking::PAST}

  if !booking_till_date.blank?
    return  sum_of_earnings(booking_till_date)
  else
    return ""
  end

end

  def self.pay_via_gift_card_micro(params,booking)

    amount_to_be_payed=params[:amount_to_be_payed]
    #gift_amount=params[:gift_amount]
    gift_card=GiftCard.find(params[:gift_card_id])
      pay_via_entire_gift=params[:pay_via_entire_gift]
    pay_half_from_gift=params[:pay_half_from_gift]
    remaining_amount=params[:remaining_amount]
    gift_card.remaining_amount=remaining_amount==0 ? 0 : remaining_amount
    Transaction.booking_success_with_successfull_transaction_message(User.current)
    booking.update(:status => Booking::PENDING)
    transaction=Transaction.new(booking_id:booking.id,gift_card_id:gift_card.id,amount_paid:amount_to_be_payed,stylist_id:booking.stylist_id)
    if pay_via_entire_gift=="true"
      gift_card.is_valid=false
      transaction.pay_via="gift_card"
    else
      transaction.pay_via="gift_card"
    end
    gift_card.save
    transaction.save

  end
  def self.transaction_sale(params,amount,settlement_value)
    unless User.current.has_payment_info?
      @result = Braintree::Transaction.sale(
          amount: amount,
          payment_method_nonce: params[:payment_method_nonce],
          customer: {
              first_name: params[:first_name],
              last_name: params[:last_name],
              company: params[:company],
              email: User.current.email,
              phone: params[:phone]
          },
          options: {
              store_in_vault: true  ,
              :submit_for_settlement => settlement_value
          })
    else
      @result = Braintree::Transaction.sale(
          amount: amount,payment_method_nonce: params[:payment_method_nonce],options:{
                                     store_in_vault: true  ,
                                     :submit_for_settlement => settlement_value
                                 }
      )
    end
  end



  def self.tot_expected_earnings(booking)

    booking_expected_date=booking.select{|booking| booking.dates.between?(Date.today,Date.today.end_of_month) && booking.status==Booking::UPCOMING}

    if !booking_expected_date.blank?
      return  sum_of_earnings(booking_expected_date)
    else
      return ""
    end

  end

  def self.sum_of_earnings(booking)
    sum=0

    booking.each do |book|
      amount=book.total_amount.to_i
      sum = sum + amount

    end
    return sum
  end

  def self.get_transaction_status(the_transaction_id)
    transaction = Braintree::Transaction.find(the_transaction_id)
    status_transaction=transaction.status
  end


  def self.booking_success_with_successfull_transaction_message(user)
    begin
      client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
      client.account.sms.messages.create(
          from: TWILIO_CONFIG['from'],
          to: "+1"+"#{user.phone if user.verified_number==true}",
          body: "Thank You for booking with Reddera, Your Appointment will be confirmed shortly"


      )
    rescue Twilio::REST::RequestError => e
      return e.message
    end
  end

  def self.delete_transaction(braintree_transaction_id,transaction_status)
    transaction=Transaction.find_by_braintree_transaction_id(braintree_transaction_id)
    transaction.update(:is_deleted=>true,:transaction_status=>transaction_status)
  end

  def self.transaction_refund(booking,the_transaction_id,amount)

    result = Braintree::Transaction.refund(the_transaction_id,((50.0/100.0).to_f * amount).to_s)
    transaction=Transaction.find_by_braintree_transaction_id(the_transaction_id)
    transaction.update(:transaction_status=>result.transaction.status,:is_deleted=>true)
    booking.update(:status=>"deleted",:is_deleted=>true)
  end
  def self.transaction_void(booking,the_transaction_id,amount)
    result = Braintree::Transaction.void(the_transaction_id)
    transaction=Transaction.find_by_braintree_transaction_id(the_transaction_id)
    transaction.update(:transaction_status=>result.transaction.status,:is_deleted=>true)

    booking.update(:status=>"deleted",:is_deleted=>true)
  end


  def self.total_amount_deducted_from_tax(service_amount)
    return (service_amount.to_i+((8.875/100)*service_amount.to_i)).round
  end

    def self.get_gift_amount(gift_card)
    gift_card.remaining_amount.blank? ? gift_card.amount : gift_card.remaining_amount
    end

  def self.transaction_history
    @transactions=[]
    transaction_all=[]
    transactions=Proc.new{|booking| Transaction.where('booking_id=? AND transaction_status = ? AND is_deleted=?',booking.id, "submitted_for_settlement" ,false).first }
    if User.current.isStylist?
      bookings= Booking.where('stylist_id=? AND is_confirmed = ? AND is_deleted=?',User.current.id, true ,false)
    else
      bookings=User.current.bookings.where(:is_confirmed=>true,:is_deleted=>false)
    end
    # transaction
    all_transactions=bookings.map(&transactions).reject{|n| n==nil}

    all_transactions.each do |trans|

      if trans.gift_card_id.blank?
        status_transaction=Transaction.get_transaction_status(trans.braintree_transaction_id)
        if status_transaction == "settled"
          trans.update(:transaction_status=>status_transaction)
        end
      end
    end
    settled_transactions=Proc.new{|booking| Transaction.where('booking_id=? AND transaction_status = ? AND is_deleted=?',booking.id, "settled" ,false) }
    itterate=lambda{|trans|transaction_all.push(trans)}
    itterate_2=lambda{|trans|transaction_all.push(trans).first}

    bookings.map(&settled_transactions).each{|transaction| transaction.map(&itterate)}
    @transactions= transaction_all.group_by(&:booking).each{|transaction| transaction.map(&itterate_2)}

  end



  def self.generate_client_token(current_user)

    if current_user.has_payment_info?
      return Braintree::ClientToken.generate(customer_id: current_user.braintree_customer_id)
    else
     return  Braintree::ClientToken.generate
    end
  end
  end
