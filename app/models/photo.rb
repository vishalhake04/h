class Photo < ActiveRecord::Base
	belongs_to :imageable, :polymorphic =>true
	has_attached_file :image, styles: {medium: "328x400>", thumb: "50x60>"}
	validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
	validates :imageable_type, :imageable_id, :presence => true

	def self.profile_image(image,id)
		photo=Photo.where(:imageable_id=>id,:imageable_type => "User").first
		image = URI.parse(format_url(image))
	  photo.update_attribute(:image,image)
	end

	def self.format_url(image)
		if image.include? "http://"
		return 	image.gsub("http", "https")
		else
			return image
		end
	end
end
