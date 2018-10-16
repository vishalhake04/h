class PreviousWorksController < ApplicationController
  skip_after_filter :intercom_rails_auto_include
  before_action :set_previous_work, only: [:show, :edit, :update, :destroy]
  before_action :modify_access!, :only=>[:edit,:show,:update,:destroy]
  before_action :auth_to_create!,:only => [:index,:create]
  def index
     @previous_works = current_user.previous_works.where(is_additional:false) if current_user.isStylist?
     @additional_photos = current_user.previous_works.where(is_additional:true) if current_user.isStylist?

  end

  def show
  end

  def new
    @previous_work = current_user.previous_works.new  if current_user.isStylist?
  end

  def edit
  end

  def create

    @previous_work = current_user.previous_works.new(previous_work_params)
    respond_to do |format|

      if @previous_work.save
        Photo.create(:image=>params[:file],:imageable_type=>@previous_work.class,:imageable_id=>@previous_work.id) if !params[:file].blank?
        format.html { redirect_to   user_previous_works_path(current_user.id), notice: 'Previous work was successfully created.' }
        format.json { render :show, status: :created, location: @previous_work }
      else
        format.html { render :new }
        format.json { render json: @previous_work.errors, status: :unprocessable_entity }
      end
    end

  end


  def update

    respond_to do |format|
      if @previous_work.update(previous_work_params)
        @previous_work.photo.update_attribute(:image,params[:file]) if !params[:file].blank?
        format.html { redirect_to  user_previous_works_path(current_user.id), notice: 'Previous work was successfully updated.' }
        format.json { render :show, status: :ok, location: @previous_work }
      else
        format.html { render :edit }
        format.json { render json: @previous_work.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @previous_work.destroy
    respond_to do |format|
      format.html { redirect_to user_previous_works_path(current_user.id), notice: 'Previous work was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_previous_work
    @previous_work = PreviousWork.find(params[:id])
  end

  def modify_access!
    return current_user == @previous_work.user ? true : unauthenticated!
  end

  def auth_to_create!
    return (current_user.isStylist?) ? true : unauthenticated!
  end

  def unauthenticated!
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'UnAuthorized Access' }
    end
  end


  def previous_work_params
    params.permit(:user_id,:description)
  end
end
