class Api::V1::PhotosController < Api::V1::BaseController

  before_action :authenticate_user!, :only => [:create]

  def create

    result = { status: "failed" ,url: ""}

    begin
      photos = Photo.where(:imageable_id=>params[:image][:item_id],:imageable_type=>params[:image][:item_type])

      image= parse_image_data(params[:image]) if params[:image]

      item = Photo.new
      if photos.size > 0
        item = photos.first
      else
        item.imageable_id = params[:item_id]
	      item.imageable_type = params[:item_type]
      end

      item.image = image
      if item.save

        result[:status] = true
        result[:url] = item.image.url(:medium)
      end

    rescue Exception => e

      Rails.logger.error "#{e.message}"
    end

    render json: result.to_json
  ensure
    clean_tempfile
  end

  def update

    params[:image] = parse_image_data(params[:image]) if params[:image]

  end

  def parse_image_data(image_data)
    @tempfile = Tempfile.new('item_image')
    @tempfile.binmode
    @tempfile.write Base64.decode64(image_data[:content])
    @tempfile.rewind

    uploaded_file = ActionDispatch::Http::UploadedFile.new(
      tempfile: @tempfile,
      filename: image_data[:filename]
    )

    uploaded_file.content_type = image_data[:content_type]
    uploaded_file
  end

  def clean_tempfile
    if @tempfile
      @tempfile.close
      @tempfile.unlink
    end
  end
end
