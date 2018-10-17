class ServiceSubCategoriesController < ApplicationController
  skip_after_filter :intercom_rails_auto_include

  def new


    @service_sub_category=ServiceSubCategory.new
    @message=params[:message] if !params[:message].blank?

  end
  def create

    if params[:service_categories][:id].blank?
      redirect_to new_service_sub_categories_path(:message=>"Service Category is Blank")
    else
      service_category=ServiceCategory.find(params[:service_categories][:id])
      new_service_sub_cat=service_category.service_sub_categories.create(service_sub_categories_params)
      respond_to do |format|

        if new_service_sub_cat.save
          Photo.create(:image=>params[:file],:imageable_type=>new_service_sub_cat.class,:imageable_id=>new_service_sub_cat.id) if !params[:file].blank?
          format.html { redirect_to new_service_sub_categories_path(message: 'Service Sub Category  was successfully created.') }
          format.json { render :show, status: :created, location: @previous_work }
        else
          format.html { render :new }
          format.json { render json: @previous_work.errors, status: :unprocessable_entity }
        end
      end
    end

  end

  def index
    respond_to do |format|
      format.html
      format.json { @services = ServiceSubCategory.search(params[:term]) }
    end
  end

  def service_sub_categories_params
    params.require(:service_sub_category).permit(:name,:description,:price)
  end
end