module BookingsHelper
  include HomeHelper
  def get_amount_paid_for_transaction_booking(booking)
    sum=0
    booking.transactions.map(&:amount_paid).each{|amount| sum+=amount.to_i}
    return sum
  end


  def transaction_actions(dateTime,user,amount,the_transaction_id,booking)

    if dateTime > 12.0
      status_transaction= get_transaction_status(the_transaction_id)
      if status_transaction == "settled"
        Transaction.transaction_refund(booking, the_transaction_id, amount)
      else
        Transaction.transaction_void(booking, the_transaction_id, amount)
      end
    else
      booking.update(:status => "", :is_deleted => true)
      Transaction.delete_transaction(the_transaction_id,status_transaction)
    end
  end

  def transaction_actions_stylist(booking,the_transaction_id,status_transaction,amount)

    if status_transaction == "settled"
      Transaction.transaction_refund(booking, the_transaction_id, amount)

    else
      Transaction.transaction_void(booking, the_transaction_id, amount)
    end
  end


  def update_gift_card_amount(transactions,amount)
    gift_card=transactions.map(&:gift_card).reject{|t| t==nil}.first
    gift_card.remaining_amount= amount.to_i + gift_card.remaining_amount.to_i
    gift_card.is_valid= gift_card.is_valid ?  gift_card.is_valid :  true
    gift_card.save
  end
end