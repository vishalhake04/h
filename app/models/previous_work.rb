class PreviousWork < ActiveRecord::Base
  belongs_to :user

  has_one :photo, :as => :imageable ,:dependent => :destroy

  after_create :attach_default_image

  def attach_default_image
    Photo.create(:imageable_type=>self.class,:imageable_id=>self.id)
  end
end
