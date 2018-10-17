class Api::V1::BookingsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :client_auth!, :only => [:create,:reschedule_client,:reschedule_confirm_client]
  before_action :stylist_auth!, :only => [:update,:earnings_for_month,:reschedule_stylist,:reschedule_confirm_stylist]
  include BookingsHelper

  def create
    begin
      booking = current_user.bookings.new(booking_params)
      booking.save
      render(json: Api::V1::BookingSerializer.new(booking).to_json)
    rescue Exception => exc
      render(json: {  status: false, message: exc.message}.to_json)
    end
  end

  def earnings_for_month

   bookings_for_earnings=Booking.where(:stylist_id => current_user.id)
   pendings=bookings_for_earnings.select{|booking| Booking.bookedDateTime(booking) >= DateTime.now && booking.status==Booking::PENDING  }
   upcomings=bookings_for_earnings.select{|booking|   Booking.bookedDateTime(booking) >= DateTime.now  && booking.status==Booking::UPCOMING}
   past=bookings_for_earnings.select{|booking|  booking.status==Booking::PAST}
   @total_earnings_till_date=Transaction.total_earnings_till_date(bookings_for_earnings)
   bookings_current_month=bookings_for_earnings.select{|booking| booking.dates.between?(Date.today.beginning_of_month,Date.today.end_of_month ) }
   @my_earnings=Transaction.my_earnings(bookings_current_month,@total_earnings_till_date)

   upcomings_count=upcomings.to_a.count

   @requests= pendings.to_a.count + upcomings_count + past.count
   @appointments=past.count + upcomings_count

   render(json:{earnings:@my_earnings,requests:@requests,appointments:@appointments}.to_json)

  end

  def booking_delete

    begin

    booking=Booking.find(params[:id])
    transactions=booking.transactions

    l = lambda {|transaction| transaction.pay_via == "gift_card" || transaction.pay_via == "pay_half_trans_and_gift"}

    transaction_gift=transactions.map(&:pay_via).include?("gift_card")
    transaction_half_trans_and_gift=transactions.map(&:pay_via).include?("pay_half_trans_and_gift")
    plain_transaction=transactions.map(&:pay_via).include?("transaction")
    the_transaction_id= transactions.select(&:braintree_transaction_id).first.braintree_transaction_id if plain_transaction || transaction_half_trans_and_gift

    gift_trans_object=transactions.select(&:gift_card).first if transaction_gift || transaction_half_trans_and_gift
    transaction_status=Transaction.get_transaction_status(the_transaction_id)  if plain_transaction || transaction_half_trans_and_gift

    if current_user.isStylist?
      if booking.status == Booking::PAST
        booking.update(:status => "", :is_deleted => true)
        render(json: { success: true, message: "Booking deleted successfully" }.to_json)
      else

        if transaction_gift
          amount=gift_trans_object.amount_paid
          update_gift_card_amount(transactions,amount)
          gift_trans_object.update(:is_deleted=>true,:transaction_status=>"voided")

        elsif transaction_half_trans_and_gift

          gift_trans=transactions.select(&:gift_card).first
          amount=gift_trans_object.amount_paid
          transaction_actions_stylist(booking,the_transaction_id,transaction_status,amount.to_i)
          update_gift_card_amount(transactions,amount)
          gift_trans.update(:is_deleted=>true,:transaction_status=>"voided")

        else
          amount=transactions.first.amount_paid
          transaction_actions_stylist(booking,the_transaction_id,transaction_status,amount.to_i)

        end
        booking.update(:status => "deleted", :is_deleted => true)
        Booking.updating_user_marked(booking)
        create_notification_client(booking, booking.user, Booking::CANCELLED)
        render(json: { success: true, message: "Booking deleted successfully" }.to_json)
      end
    else

      if booking.status == Booking::PAST
        booking.update(:status => "", :is_deleted => true)
        render(json: { success: true, message: "Booking deleted successfully" }.to_json)

      else

        date=booking.dates
        time=booking.slots.slice(0, 7)
        dateTime=Booking.date_time(date, time)
        user=booking.stylist
        if transaction_gift
          amount=gift_trans_object.amount_paid
          gift_trans_object.update(:is_deleted=>true,:transaction_status=>"voided")
          update_gift_card_amount(transactions,amount)

        elsif transaction_half_trans_and_gift
          amount=transactions.select(&:braintree_transaction_id).first.amount_paid
          gift_amount=gift_trans_object.amount_paid
          gift_trans_object.update(:is_deleted=>true,:transaction_status=>"voided")
          transaction_actions(dateTime,user,amount,the_transaction_id,booking)
          update_gift_card_amount(transactions,gift_amount)

        else

          amount=transactions.first.amount_paid
          transaction_actions(dateTime,user,amount,the_transaction_id,booking)

        end
        booking.update(:status => "deleted", :is_deleted => true)
        create_notification_stylist(booking, user, Booking::CANCELLED)
        render(json: { success: true, message: "Booking deleted successfully" }.to_json)

      end

    end

    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end


  def update

    booking = Booking.update_booking(params[:id])

    if booking.nil?
      render(json: { success: true, message: "Cannot Update Booking" }.to_json)

    else
       User.send_push_notification_ios("Booking confirmed by the stylist successfully")
       render(json: { success: true, message: "Booking updated successfully" }.to_json)

    end
  end

  def reschedule_stylist
    begin
    booking=Booking.find(params[:id])
    if current_user==booking.stylist
      booking.update(:rescheduled_time => [params[:booking][:rescheduled_time]], :status => Booking::RESCHEDULE_STYLIST, :is_confirmed => false)
      user=booking.user
      create_notification_reschedule_client(booking, user,"rescheduled")
      render(json: { success: true, message: "Booking rescheduled successfully" }.to_json)
    else
     unauthenticated!
    end
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  def reschedule_client

  begin
    booking=Booking.find(params[:id])
    if current_user==booking.user
      dates=params[:booking][:dates]
      slots=params[:booking][:slots]
      create_notification_reschedule_stylist(booking,booking.stylist,dates,slots)

      booking.update(:dates => params[:booking][:dates], :slots => params[:booking][:slots], :is_confirmed => false, :status => "reschedule by client")
      render(json: { success: true, message: "Booking rescheduled successfully" }.to_json)

    else
      unauthenticated!
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end
  end

  def reschedule_confirm_stylist
    begin
      booking=Booking.find(params[:id])
      if current_user==booking.stylist
        booking.update(:status => Booking::UPCOMING, :is_confirmed => true)
        render(json: { success: true, message: "Rescheduled booking confirmed by stylist successfully" }.to_json)
      else
        unauthenticated!
      end
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  def reschedule_confirm_client

    begin
      booking=Booking.find(params[:id])

      if current_user==booking.user
      booking.update(:rescheduled_time => [], :is_confirmed => true, :slots => params[:booking][:selectedTime], :dates => params[:booking][:date], :status => Booking::UPCOMING)
      stylist=booking.stylist
      client_confirm_reschedule(booking, stylist,status)
        render(json: { success: true, message: "Rescheduled booking confirmed by client successfully" }.to_json)
      else
        unauthenticated!
      end
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  def index

    if current_user.isStylist?

	    pendings=current_user.appointments.where(:status=>Booking::PENDING)
	    upcomings=current_user.appointments.where(:status=>Booking::UPCOMING)
    else
      pendings=current_user.bookings.where(:status=>Booking::PENDING)
      upcomings=current_user.bookings.where(:status=>Booking::UPCOMING)
    end
    render json: {bookings:{pendings:ActiveModel::ArraySerializer.new(pendings, each_serializer: Api::V1::BookingSerializer),upcomings:ActiveModel::ArraySerializer.new(upcomings, each_serializer: Api::V1::BookingSerializer)}}.to_json



    # render(json:upcomings,each_serializer: Api::V1::BookingSerializer, root: 'pendings')
  end

  protected

  def getBookingJson(booking)
	  render(json: Api::V1::BookingSerializer.new(booking).to_json)
  end

  def client_auth!
    return (current_user.isClient?) ? true : unauthenticated!
  end

  def stylist_auth!
    return (current_user.isStylist?) ? true : unauthenticated!
  end




  def booking_params
    params.require(:booking).permit(:dates, :slots, :service_id, :stylist_id,:total_amount,:total_time,:rescheduled_time,:multiple_services => [])
  end
end
