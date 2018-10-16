class ServicesController < ApplicationController
  skip_after_filter :intercom_rails_auto_include
  skip_before_action :verify_authenticity_token,:only=>[:create_service,:sort_services]
  before_action :authenticate_user!, :except => [:search, :show,:sort_services]
  before_action :set_service, only: [:show, :edit, :update, :destroy]
  before_action :modify_access!, :only=>[:edit,:show,:update,:destroy]
  before_action :auth_to_create!,:only => [:index,:create]

  def search
    @previous_works=[]
    @availabilities = Availability::TIMEOBJ
    @services=Service.filter_services(params).paginate(:per_page => 12, :page => params[:page])
    @users=@services.map(&:user).uniq

    @services.each do |service|

      previous_works=service.user.previous_works
      previous_works.each {|prev|@previous_works.push(prev)}


      @service_cat_blank= params[:name].blank? ? true : false
      end
    #@previous_works=@services.where
    gon.service_names=Service.getServiceNameList
  end

  def index

    @services = current_user.services.where(:is_deleted=>false)
   # @service_categories=ServiceCategory.all.map(&:name)

  end


  def show
  end
  def cities
    @locations =CS.cities(params[:state], :us)
    @services=current_user.services
    respond_to do |format|
      format.js{render :file=> 'services/create_service.js.erb'}
    end

  end
 def create_service


   @service=current_user.services.create(service_params)

   respond_to do |format|

     if !@service.id.blank?

       #ServicePhoto.create(:image=>params[:file],:imageable_type=>@service.class,:imageable_id=>@service.id) if !params[:file].blank?

       @services=current_user.services.where(:is_deleted=>false)

       format.js

     else

       @services=current_user.services.where(:is_deleted=>false)
       service_category=ServiceCategory.find(params[:service][:service_category_id])
       service_sub_category=ServiceSubCategory.find(params[:service][:service_sub_category_id])

       @message="Service #{service_sub_category.name} - #{service_category.name} with amount $#{params[:service][:amount]} and time #{params[:service][:time]}mins already exists"
       format.js

     end
   end
 end

  def new
    @service = current_user.services.new if current_user.isStylist? || current_user.isAdmin?
  end

  def edit

    respond_to do |format|
      service=[]
      @service=Service.find(params[:id])
      service.push(@service)
      @sub_services=service.map{|service| service.service_sub_category}

      @edit=true
      format.js

    end
    end



  def sort_services

    @services=[]
    services=Service.filter_services(params)
    price=params[:price]
    price1=price.split('-')[0].to_i
    price2=price.split('-')[1].to_i

    @services=services.select{ |service| service.amount.between?(price1,price2) if !service.blank?}.paginate(:per_page => 12, :page => params[:page])

    respond_to do |format|
      format.js
     end
    end


  def update

    begin

     value= @service.update(service_params)
     if value==false
       @message="Service Already exists"
     else
       @message="Service updated"
     end
     @services=current_user.services.where(:is_deleted=>false)

      respond_to do |format|
        format.js
      end

    rescue Exception => exc
      @services=current_user.services.where(:is_deleted=>false)
      @message="Fields cannot be blank"

      respond_to do |format|
        format.js
      end
    end

    # respond_to do |format|
    #   if @service.update(service_params)
		 #    @service.photo.update_attribute(:image,params[:file]) if !params[:file].blank?
    #     format.html { redirect_to user_services_path(current_user.id), notice: 'Service was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @service }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @service.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  def destroy_service
     
    service=Service.find(params[:id])
     service.is_deleted=true
     service.save
      @services=current_user.services.where(:is_deleted=>false)

    respond_to do |format|
      format.js{render :file=> 'services/create_service'}
    end
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def modify_access!
    return current_user == @service.user ? true : unauthenticated!
  end

  def auth_to_create!
    return (current_user.isStylist?) ? true : unauthenticated!
  end

  def unauthenticated!
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'UnAuthorized Access' }
    end
  end

  def service_params
    params.require(:service).permit(:name, :amount, :user_id,:service_category_id ,:service_sub_category_id,:avatar, :time,:description,:location1,:location2,:location3,:location4,:location5)
  end
end
