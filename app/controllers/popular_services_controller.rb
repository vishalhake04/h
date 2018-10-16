class PopularServicesController < ApplicationController
  skip_after_filter :intercom_rails_auto_include
  skip_before_action :verify_authenticity_token ,:only => [:update]
  before_action :set_previous_work, only: [:show, :edit, :update, :destroy],except:[:new]

  def new
    if user_signed_in? && current_user.isAdmin?
      @popular_service=PopularService.new
      @popular_service=PopularService.order(:id)
    else
      not_found
    end

  end
  def update

    respond_to do |format|
      if @popular_service.update(:service_sub_category_id=>params[:service_category].to_i)
        @popular_service.photo.update_attribute(:image,params[:file]) if !params[:file].blank?
        format.html { redirect_to  new_popular_services_path, notice: 'Previous work was successfully updated.' }
        format.json { render :show, status: :ok, location: @previous_work }
      else
        format.html { render :edit }
        format.json { render json: @previous_work.errors, status: :unprocessable_entity }
      end
    end
  end

  def set_previous_work
    @popular_service = PopularService.find(params[:id])
  end
  def previous_work_params
    params.permit(:user_id,:description)
  end
end