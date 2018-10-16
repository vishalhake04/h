  class ServiceCategoriesController < ApplicationController
    skip_after_filter :intercom_rails_auto_include
    skip_before_filter :verify_authenticity_token
    def get_sub_categories_by_service_category
      @sub_services= ServiceSubCategory.where(:service_category_id=>params[:id])
      @id_dropdown=params[:name]
      respond_to do |format|
        format.js{render :file=> 'services/'+@id_dropdown+'.js.erb'}
      end
    end

  def new
@alert=params[:notice] if !params[:notice].blank?
   @service_category=ServiceCategory.new
  end
    def create
    
      service_cat=ServiceCategory.create(service_category_params)
      respond_to do |format|

        if service_cat.save
          Photo.create(:image=>params[:file],:imageable_type=>service_cat.class,:imageable_id=>service_cat.id) if !params[:file].blank?
          format.html { redirect_to new_service_categories_path(notice: 'Service Category  was successfully created.') }
          format.json { render :show, status: :created, location: @previous_work }
        else
          format.html { render :new }
          format.json { render json: @previous_work.errors, status: :unprocessable_entity }
        end
      end
    end

    def service_category_params
      params.require(:service_category).permit(:name)
    end
end
