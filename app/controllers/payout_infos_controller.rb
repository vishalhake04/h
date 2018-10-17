class PayoutInfosController < ApplicationController
  skip_after_filter :intercom_rails_auto_include

  def payment_info
    paymenInfo=PayoutInfo.find_by_user_id(params[:user_id])
    paymenInfo.update(:legal_name=>params[:payout_info][:legal_name],:business_name=>params[:payout_info][:business_name],:tax_id=>params[:payout_info][:tax_id],:dob=>params[:payout_info][:dob],:ssn=>params[:payout_info][:ssn],:account_number=>params[:payout_info][:account_number],:routing_number=>params[:payout_info][:routing_number],:street_address=>params[:payout_info][:street_address],:city=>params[:payout_info][:city],:state=>[:state],:zipcode=>params[:payout_info][:zipcode])
    redirect_to user_dashboard_path(current_user)
  end


end