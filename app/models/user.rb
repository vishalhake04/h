class User < ActiveRecord::Base
  has_many :votes

  # Include default devise modules.
  devise :omniauthable, :database_authenticatable, :registerable, :confirmable,
           :recoverable, :rememberable, :trackable, :validatable #:omniauth_providers => [:facebook],[:]

  #validates_presence_of :first_name,:last_name,:stylist_type,:description
  geocoded_by :address
  after_validation :geocode, :if => :address_changed?
  belongs_to :role
  has_many :gift_cards
  has_many :previous_works
  has_many :services
  has_many :gifts,:foreign_key => 'gift_owner_id', :class_name => "GiftCard"
  has_many :availabilities
  has_many :reviews
  has_many :notifications
  has_many :notices, :foreign_key => "stylist_id", :class_name => "Notification"
  has_many :messages
  has_many :message_data, :foreign_key => "stylist_id", :class_name => "Message"
  has_many :recommendations, :foreign_key => "stylist_id", :class_name => "Review"
  has_many :bookings
  has_many :appointments, :foreign_key => "stylist_id", :class_name => "Booking"
  has_one :payout_details, class_name: "PayoutInfo"
  has_many :update_availabilities
  has_one :photo, :as => :imageable
  has_many :accounts_history ,:foreign_key => "stylist_id", :class_name => "Transaction"
  has_many :favourite_list_stylist ,:foreign_key => "stylist_id", :class_name => "FavouriteStylist"
  has_many :favourite_stylists
  has_many :featured_professionals
  has_many :recently_bookeds


  after_create :create_availability,:attach_default_image, :create_previous_work,:create_payout_information
  before_create :generate_authentication_token

  PIN_BLANK_MESSAGE="Enetered pin is blank"
  INCORRECT_PIN_MESSAGE="Entered pin is incorrect"


  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def self.find_for_facebook_oauth(phone,gender,image,provider, uid, email, name, role_id, signed_in_resource=nil)

    user = User.where(:provider => provider, :uid => uid).first

    if user
      return user
    else
      registered_user = User.where(:email => email).first
      if registered_user
        return registered_user
      else
        if role_id=="not_registered"

          return user
        else
          user = User.new(first_name: name,
                          provider: provider,
                          uid: uid,
                          gender:gender,
                          phone:phone,
                          email: email,
                          password: Devise.friendly_token[0, 20],
                          :role_id => role_id,
          )

          user.skip_confirmation!
          user.save!

          Photo.profile_image(image,user.id) if !image.blank?
          return user

        end
      end

    end

  end





  def self.find_for_google_oauth2(phone,gender,image,provider, uid, email, name, role_id, signed_in_resource=nil)
   begin
    user = User.where(:provider => provider, :uid => uid).first
    if user
      return message="Please registe to login"
    else
      registered_user = User.where(:email => email).first
      if registered_user
        return registered_user
      else
        if role_id=="not_registered"
          return user
        else
          user = User.new(first_name: name,
                          provider: provider,
                          email: email,
                          gender:gender,
                          phone:phone,
                          uid: uid,
                          password: Devise.friendly_token[0, 20],
                          role_id: role_id,


          )

          user.skip_confirmation!
          user.save!
          Photo.profile_image(image,user.id) if !image.blank?

          return user

        end
      end
    end

   rescue Exception => exc
      message="Email is already Taken"
   end
  end




  def self.send_push_notification_ios(message)
    channels=self.get_channels_through_named_user_id
    if !channels.blank?
      self.send_push_notification_to_channels(channels,message)
    end
  end

  def self.get_channels_through_named_user_id
    begin

      named_user_id='user_id'+'-'+User.current.id
      ua = Urbanairship
      airship = ua::Client.new(key:'1hDk8co4QY29YWD7tWqGnA', secret:'TbTeIR7yRT--PhwS9nyU-g')
      named_user = ua::NamedUser.new(client: airship)
      named_user.named_user_id = named_user_id
      named_user.lookup["body"]["named_user"]["channels"].select{|object| object["device_type"]=="ios"}

    rescue Exception => exc

    end


  end

  def self.send_push_notification_to_channels(channels,message)

    channels.each do |channel|
      ua             = Urbanairship
      client         = Urbanairship::Client.new(key:"1hDk8co4QY29YWD7tWqGnA", secret:"TbTeIR7yRT--PhwS9nyU-g")
      p              = client.create_push
      p.audience     = Urbanairship.ios_channel(channel["channel_id"])
      p.notification = Urbanairship.notification(ios: Urbanairship.ios(alert: message))
      p.device_types = Urbanairship.device_types(["ios"])
      p.send_push
    end
  end

  def has_payment_info?
    braintree_customer_id
  end


  def active_for_authentication?
    super && self.confirmed_at # i.e. super && self.is_active

  end

  def inactive_message
    # self.confirmed_at ? super : :confirmed_at_is_not_valid

  end

  def create_availability
    if isStylist?
      self.availabilities.create([
                                     {:time => '06AM'}, {:time => '07AM'}, {:time => '08AM'}, {:time => '09AM'}, {:time => '10AM'}, {:time => '11AM'},
                                     {:time => '12PM'}, {:time => '01PM'}, {:time => '02PM'}, {:time => '03PM'}, {:time => '04PM'}, {:time => '05PM'},
                                     {:time => '06PM'}, {:time => '07PM'}, {:time => '08PM'}, {:time => '09PM'}, {:time => '10PM'}, {:time => '11PM'}
                                 ])
    end
  end


  def generate_pin
    self.pin = rand(0000..9999).to_s.rjust(4, "0")
    save
  end

  def twilio_client
    Twilio::REST::Client.new(TWILIO_CONFIG['sid'], TWILIO_CONFIG['token'])
  end

  def send_pin(number)

  begin
    response=twilio_client.messages.create(
        to: "+1"+"#{number}",
        from: TWILIO_CONFIG['from'],
        body: "Your PIN is #{pin}"

    )
    return "Message Sent successfully on number +1#{number}"
  rescue Twilio::REST::RequestError => e
    return e.message
  end
  end

  def verify(entered_pin)
    update(verified_number: true) if self.pin == entered_pin
  end

  def isStylist?
    self.role_id == Role::STYLIST ? true : false
  end

  def isClient?
    self.role_id == Role::CLIENT ? true : false
  end

  def isAdmin?
    self.role_id == Role::ADMIN ? true : false
  end

  protected


  def generate_authentication_token
    loop do
      self.authentication_token = SecureRandom.base64(64)
      break unless User.find_by(authentication_token: authentication_token)
    end
  end

  def confirmation_required?
    false
  end

  def attach_default_image
    Photo.create(:imageable_type => self.class, :imageable_id => self.id)
  end

  def self.insta_array_loop(insta_array)
    portfolio_array=[]
    for i in insta_array[1..5]
      insta_array.reject{|b| portfolio_array.push(b) }
    end
    return portfolio_array
  end

  def create_payout_information
    if self.isStylist?
      PayoutInfo.create(:user_id=>self.id)
    end
  end

  def create_previous_work
    if self.isStylist?
      5.times do |i|
        self.previous_works.create(:legend => "#work #{i}")
      end
      10.times do |i|
        self.previous_works.create(:is_additional=>true)
      end
    end
  end

end
