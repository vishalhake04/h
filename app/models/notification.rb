class Notification < ActiveRecord::Base
  belongs_to  :user
  belongs_to :stylist,:foreign_key => "stylist_id",:class_name => "User"
  belongs_to :booking

  def self.create_notification_record(message,booking_id,user_id,stylist_id)
    Notification.create(:message=>message,:booking_id=>booking_id,:user_id=>user_id,:stylist_id=>stylist_id)
  end
end
