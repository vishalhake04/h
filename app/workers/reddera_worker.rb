class RedderaWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  include HomeHelper

  def perform(id,the_transaction_id)

    booking=Booking.find(id)
    if booking.status==Booking::PENDING
      result = Braintree::Transaction.submit_for_settlement(the_transaction_id)

      if result.success?
        booking.update(:status=>Booking::UPCOMING , :is_confirmed=>true)
        transaction=Transaction.find_by_braintree_transaction_id(the_transaction_id)
        transaction.update(:transaction_status=>result.transaction.status)
        date=booking.dates
        time=booking.slots.slice(0,7)
        dateTime=Booking.date_time(date,time)
        @pendings=Booking.where(:status=>Booking::PENDING, :stylist_id=>booking.stylist_id)
        @upcomings=Booking.where(:status=>Booking::UPCOMING, :stylist_id=>booking.stylist_id)
        @past=Booking.where(:status=>Booking::PAST,:stylist_id=>booking.stylist_id)
        Notification.create(:message=>"Booking is Confirmed",:stylist_id=>booking.stylist_id,:user_id=>booking.user_id)
        user=booking.user
        create_notification_client(booking,user,Booking::CONFIRM)

        AppointmentMessage.perform_at(dateTime.hours.from_now,booking.id)


      end
    end
  end
end