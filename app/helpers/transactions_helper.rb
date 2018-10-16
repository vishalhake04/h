module TransactionsHelper
 def get_amount_paid_for_tranaction(trans)
  sum=0
   if trans.size==1
   trans.first.amount_paid
   else
    trans.map(&:amount_paid).each{|amount| sum+=amount.to_i}
    return sum
   end
 end

 def discounted_price_calculation(total_amount,gift_amount)
  gift_deducted_amount=lambda{|a,b| a - b}

  if total_amount==gift_amount

   @pay_via_entire_gift=true
   gift_deducted_amount=gift_deducted_amount.call(total_amount,gift_amount)
   @json={gift_deducted_amount:gift_deducted_amount,gift_remaining_amount:gift_deducted_amount,discounted_amount:gift_amount,amount_to_be_payed:gift_amount,pay_via_entire_gift:true,pay_half_trans_and_full_gift:false,pay_half_from_gift:false}

  elsif total_amount > gift_amount

   @pay_half_trans_and_full_gift=true
   gift_deducted_amount=gift_deducted_amount.call(total_amount,gift_amount)
   @json={gift_deducted_amount:gift_deducted_amount,gift_remaining_amount:0,discounted_amount:gift_amount,amount_to_be_payed:gift_deducted_amount,pay_via_entire_gift:false,pay_half_trans_and_full_gift:true,pay_half_from_gift:false}

   session[:pay_half_trans_and_full_gift]=true
  else

   @pay_half_from_gift=true
   @gift_deducted_amount=gift_deducted_amount.call(gift_amount,total_amount)
   @json={gift_deducted_amount:0,gift_remaining_amount:@gift_deducted_amount,discounted_amount:@total_amount,amount_to_be_payed:@total_amount,pay_via_entire_gift:false,pay_half_trans_and_full_gift:false,pay_half_from_gift:true}
  end
 end

 def update_gift_card(gift_card)
  gift_card.remaining_amount=0
  gift_card.is_valid=false
  gift_card.save
 end

 def check_coupon_validity(gift_card)
  gift_card.is_valid == true ? false : true
 end
end