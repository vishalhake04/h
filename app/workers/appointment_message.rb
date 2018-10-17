class AppointmentMessage
  include Sidekiq::Worker
  def perform(id)
    booking=Booking.find(id)

    if !(booking.status == Booking::UPCOMING)

      begin
        client = Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
        client.account.sms.messages.create(
            from: TWILIO_CONFIG['from'],
            to: "+15027916322",
            body:"you  have 15minutes left for your appointment "


        )
      rescue Twilio::REST::RequestError => e
        return e.message
      end
    end
  end
end
