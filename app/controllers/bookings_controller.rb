class BookingsController < ApplicationController
  skip_after_filter :intercom_rails_auto_include
  skip_before_action :verify_authenticity_token
  require 'date'
  include HomeHelper,BookingsHelper
  #before_action :authenticate_user!

  def create

    session[:booking_id]=nil
    session[:message]=nil
    session[:forReschedulebookingId]=nil
    booking = current_user.bookings.new(booking_params)
    booking.save
    session[:booking_id]=booking.id
    session[:user_id]=booking.user_id
    session[:forReschedulebookingId]=params[:booking][:forReschedulebookingId] if !params[:booking][:forReschedulebookingId].blank?
    session[:message]=params[:booking][:message] if !params[:booking][:message].blank?
    render :js => "window.location = '/transactions/new'"
  end



  def update

    booking= Booking.update_booking(params[:id])

    my_bookings(booking)
  end

  def reschedule_stylist

    booking=Booking.find(params[:id])
    booking.update(:rescheduled_time => [params[:booking][:rescheduled_time]["0"]], :status => Booking::RESCHEDULE_STYLIST, :is_confirmed => false)
    user=booking.user
    create_notification_reschedule_client(booking, user,"rescheduled")
    render :js => "window.location = '/users/#{booking.stylist.id}/bookings'"

  end

  def booking_delete

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
        my_bookings(booking)
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
        my_bookings(booking)
      end
    else

      if booking.status == Booking::PAST
        booking.update(:status => "", :is_deleted => true)
        my_bookings(booking)

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
        render :js => "window.location = '/users/#{booking.user.id}/bookings'"

      end

    end


  end

  def reschedule_client

    booking=Booking.find(params[:booking][:forReschedulebookingId])
      dates=params[:booking][:dates]
    slots=params[:booking][:slots]
    create_notification_reschedule_stylist(booking,booking.stylist,dates,slots)

    booking.update(:dates => params[:booking][:dates], :slots => params[:booking][:slots], :is_confirmed => false, :status => "reschedule by client")


    render :js => "window.location = '/users/#{booking.user.id}/bookings'"

  end

  def index

    if current_user.isStylist?

      bookings= Booking.where(:stylist_id=>params[:user_id])
      pendings=bookings.where(:status => Booking::PENDING)
      upcomings=bookings.where(:status => Booking::UPCOMING)
      past=bookings.select{ |booking| booking.dates<Date.today}
      past2=past.each { |x| x.update(:status => "past") }
      @past=past2.paginate(:per_page => 5, :page => params[:past_page])
      @pendings=pendings.paginate(:per_page => 5, :page => params[:pending_page])
      @upcomings=upcomings.paginate(:per_page => 5, :page => params[:upcoming_page])
      reschedule_stylist=Booking.where(:stylist_id => current_user.id, :status => Booking::RESCHEDULE_CLIENT)
      @reschedule_stylist=reschedule_stylist.paginate(:per_page => 5, :page => params[:page])
      # reschedule_client=current_user.bookings.where(:status=>Booking::RESCHEDULE_STYLIST)
      # @reschedule_client=reschedule_client.paginate(:per_page => 5, :page => params[:page])

      respond_to do |format|
        format.html if request.format.html? == true
        format.js { render :file => 'bookings/update.js.erb' } if request.format.js? == true
      end

    else

      @pendings=current_user.bookings.where(:status => Booking::PENDING).paginate(:per_page => 5, :page => params[:upcoming_page])
      @upcomings=current_user.bookings.where(:status => Booking::UPCOMING).paginate(:per_page => 5, :page => params[:upcoming_page])
      past=Booking.select { |booking| booking.dates<Date.today && booking.user_id == current_user.id }

      reschedule_stylist=current_user.bookings.where(:status => Booking::RESCHEDULE_CLIENT)
      @reschedule_stylist=reschedule_stylist.paginate(:per_page => 5, :page => params[:page]).paginate(:per_page => 5, :page => params[:upcoming_page])
      reschedule_client=current_user.bookings.where(:status => Booking::RESCHEDULE_STYLIST)
      @reschedule_client=reschedule_client.paginate(:per_page => 5, :page => params[:page]).paginate(:per_page => 5, :page => params[:upcoming_page])
      past2=past.each{ |x| x.update(:status => "past") }
      @past=past2.paginate(:per_page => 5, :page => params[:past_page])

    end
  end

  def reschedule_confirm_stylist

    booking=Booking.find(params[:id])
    booking.update(:status => Booking::UPCOMING, :is_confirmed => true)
    my_bookings(booking)

  end

  def reschedule_confirm_client

    booking=Booking.find(params[:id])
    booking.update(:rescheduled_time => [], :is_confirmed => true, :slots => params[:booking][:selectedTime], :dates => params[:booking][:date], :status => Booking::UPCOMING)
    stylist=booking.stylist
    client_confirm_reschedule(booking, stylist,status)
    render :js => "window.location = '/users/#{booking.user.id}/bookings'"

  end

  private

  def for_pagination(booking)

  end

  def my_bookings(booking)

    past=Booking.where(:status => Booking::PAST)
    upcomings=Booking.where(:status => Booking::UPCOMING, :stylist_id => booking.stylist.id)
    pendings=Booking.where(:status => Booking::PENDING, :stylist_id => booking.stylist.id)
    @past=past.paginate(:per_page => 5, :page => params[:page])
    @pendings=pendings.paginate(:per_page => 5, :page => params[:page])
    @upcomings=upcomings.paginate(:per_page => 5, :page => params[:page])
    reschedule_stylist=current_user.bookings.where(:status => Booking::RESCHEDULE_STYLIST)
    @reschedule_stylist=reschedule_stylist.paginate(:per_page => 5, :page => params[:page])
    reschedule_client=current_user.bookings.where(:status => Booking::RESCHEDULE_CLIENT)
    @reschedule_client=reschedule_client.paginate(:per_page => 5, :page => params[:page])

    respond_to do |format|
      format.js { render :file => 'bookings/update.js.erb' }
    end
  end

  def booking_params
    params.require(:booking).permit(:dates, :slots, :service_id, :stylist_id, :multiple_services,:rescheduled_time,:total_amount,:total_time,:multiple_services => [])
  end




  end
