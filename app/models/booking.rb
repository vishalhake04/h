class Booking < ActiveRecord::Base
  include HomeHelper

  require 'date'
  belongs_to  :user
  belongs_to  :service
  has_many :notifications
  has_many :transactions
  belongs_to :stylist ,class_name:'User',:foreign_key => "stylist_id"

  UPCOMING="upcoming"
  PENDING="pending"
  PAST="past"
  RESCHEDULE_STYLIST="reschedule by stylist"
  RESCHEDULE_CLIENT="reschedule by client"
  CONFIRM="confirmed"
  CANCELLED="cancelled"


  def self.getBookings(user)
    bookingList = []


      bookings= Booking.where('stylist_id=? AND status = ? OR status = ? AND dates >= ?  AND is_deleted=?',user.id, UPCOMING , PENDING, Date.today,false)

       # bookings=all_bookings.select{|book|book.is_deleted==false}


      if !bookings.blank?
        bookings.each do |booking|
          jsonString = {'date' => booking.dates.to_s, 'time' => booking.slots}
          bookingList.push(jsonString)

        end


    end

    return bookingList.to_s.gsub("=>",":")
  end


  def self.getAvaliabilities(user)
    availList=[]
    availabilities=user.availabilities
    availabilities.each do |availability|
      jsonString = {'time' => availability.time, 'mon' => availability.mon, 'tue' => availability.tue, 'wed' => availability.wed, 'thu' => availability.thu, 'fri' => availability.fri, 'sat' => availability.sat, 'sun' => availability.sun}
      availList.push(jsonString)
    end
    return availList.to_s.gsub("=>",":")
  end

  def self.bookedDateTime(booking)
    time=booking.slots.slice(0,7).gsub(".",":")
    date=booking.dates
    dateString="#{date} #{time}+05:30"
    return DateTime.parse(dateString)
  end

  def self.date_time(date,time)
    time=time.gsub(".",":")
    time=(time.to_time - 15.minutes).strftime("%H:%M")
    dateString="#{date} #{time}+05:30"
    futureDate=DateTime.parse(dateString)
    dateDiff= (Time.parse(futureDate.to_s) - Time.parse(DateTime.now.to_s))/1.hour
    return dateDiff
  end


  def self.update_booking(id)

     booking=Booking.find(id)

     transactions=booking.transactions
     transaction_gift=transactions.map(&:pay_via).include?("gift_card")
     plain_transaction=transactions.map(&:pay_via).include?("transaction")
     pay_half_trans_and_gift=transactions.map(&:pay_via).include?("pay_half_trans_and_gift")
     gift_trans_object=transactions.select(&:gift_card).first if transaction_gift || pay_half_trans_and_gift


   if transaction_gift
       self.update_booking_micro(booking)
       gift_trans_object.update(:transaction_status=>"settled")
       return booking


     elsif plain_transaction || pay_half_trans_and_gift
       the_transaction_id=transactions.select(&:braintree_transaction_id).first.braintree_transaction_id
       result = Braintree::Transaction.submit_for_settlement(the_transaction_id)

      if result.success?
        transaction=Transaction.find_by_braintree_transaction_id(the_transaction_id)
        transaction.update(:transaction_status=>result.transaction.status)
        gift_trans_object.update(:transaction_status=>"settled") if pay_half_trans_and_gift

        self.update_booking_micro(booking)
        return booking
      else
        return booking
      end
     end


  end



  def self.reschedule(id,currentBookingID,current_user)

    booking= Booking.find(id)
    currentBooking=Booking.find(currentBookingID)

    the_transaction_id=booking.payment.braintree_transaction_id
    transaction = Braintree::Transaction.find(the_transaction_id)
    status_transaction=transaction.status
    if Transaction::TRANSACTION_STATUS_REFUND.include?status_transaction
      result = Braintree::Transaction.refund(the_transaction_id)
      Transaction.delete_transaction(the_transaction_id,result.transaction.status)

      begin
        client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
        client.account.sms.messages.create(
            from: TWILIO_CONFIG['from'],
            to: "+15027916322",
            body:"A refund has been initiated to your account,kindly reschedule your Appointment for service #{Booking.get_services_name_by_booking(booking)}"



        )
      rescue Twilio::REST::RequestError => e
        return e.message
      end

    else

      if  Transaction::TRANSACTION_STATUS_VOID.include?status_transaction
        result = Braintree::Transaction.void(the_transaction_id)
        Transaction.delete_transaction(the_transaction_id,result.transaction.status)


        begin
          client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
          client.account.sms.messages.create(
              from: TWILIO_CONFIG['from'],
              to: "+15027916322",
              body:"kindly reschedule your Appointment for service #{Booking.get_services_name_by_booking(booking)} with stylist #{booking.stylist.name}"


          )
        rescue Twilio::REST::RequestError => e
          return e.message
        end
      end
    end

   BookingsController.helpers.create_notification_client(booking,booking.user,Booking::RESCHEDULE) if current_user.isStylist?
   BookingsController.helpers.create_notification_reschedule_stylist(booking,currentBooking,booking.stylist,Booking::RESCHEDULE) if current_user.isClient?
   booking.update(:status=>Booking::RESCHEDULE , :is_confirmed=>false,:is_deleted=>true)

return booking

  end

  def self.updating_user_marked(booking)

    user=booking.stylist
    client=booking.user
    if user.marked.blank?
      user.update(:marked=>"1")
    elsif user.marked=="1"
      user.update(:marked=>"2")
    elsif user.marked=="2"
      user.update(:marked=>"3")
    end
  end


  def self.get_services_name_by_booking(booking)
    begin
    if !booking.multiple_services.blank?
    services=booking.multiple_services.collect{|id|Service.find(id) }
    services_name=services.collect{|service| service.service_sub_category.name}
    return services_name.join(',')
    end
    rescue ActiveRecord::RecordNotFound
      return " "
    end

  end


  def self.update_booking_micro(booking)
    user=booking.user
    date=booking.dates
    time=booking.slots.slice(0,7)
    dateTime=Booking.date_time(date,time)

    booking.update(:status=>Booking::UPCOMING , :is_confirmed=>true)

    BookingsController.helpers.create_notification_client(booking,user,Booking::CONFIRM)

    AppointmentMessage.perform_at(dateTime.hours.from_now,booking.id)
  end
  # def self.get_services_duration_by_booking_id(booking)
  #   count=0
  #   if !booking.multiple_services.blank? services=booking.multiple_services.collect{|id|Service.find(id) }
  #   service_time_array=services.collect{|service| service.time+=count}
  #   service_time=service_time_array.inject(0){|sum,x| sum + x }
  #   return service_time
  #   end
  # end
end
