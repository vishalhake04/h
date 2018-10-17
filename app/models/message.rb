class Message < ActiveRecord::Base
  belongs_to  :user
  belongs_to :stylist,:foreign_key => "stylist_id",:class_name => "User"
  def self.create_message_record(message,stylist_id,user_id)
    self.create(:message=>message,:user_id=>user_id,:stylist_id=>stylist_id)
  end
end
