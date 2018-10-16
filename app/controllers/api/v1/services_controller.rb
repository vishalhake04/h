class Api::V1::ServicesController < Api::V1::BaseController

  #skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, :only => [:create, :update,:destroy,:modify_access!,:auth_to_create!]
  before_action :set_service, only: [:show, :update, :destroy,:modify_access!]
  before_action :modify_access!, :only => [:update,:destroy]
  before_action :auth_to_create!,:only=>[:create,:update,:destroy]

  def search

    services=Service.filter_services(params).paginate(:per_page => 5,:page => params[:page])
    getServicesListJson(services)
  end

  def getUsersByservice

    services=Service.getServiceByName(params)
    users=services.map(&:user)
    getUsersListJson(users)


  end

  def get_sorted_services

   user=User.find(params[:user_id])
   services=user.services.where(:is_deleted=>false).shuffle
   getServicesListJson(services)
  end

  def get_sub_services_clubbed_services_f_service_category_id
    begin
    sub_services=[]
    service_category=ServiceCategory.find(params[:id])
    services=service_category.services.select("*").joins(:service_sub_category)

    services.each{|service|sub_services.push(Api::V1::ServiceSubCategorySerializer.new(service.service_sub_category,root:false,scope:{amount:service.amount,time:service.time}))}

    #all_services=sub_services.map{|service| service.to_json}

    #jsonObj = '[{"id"":2, "name":"satendra"}]'.to_json
    render(json:{sub_services:sub_services}.to_json)
    rescue ActiveRecord::RecordNotFound
      not_found_for_services
    end    # service_category=ServiceCategory.find(params[:id])
    # services=service_category.services
    #
    #render(json:services,each_serializer: Api::V1::ServiceSubCategorySerializer)
    #


  end


  def update

    begin

      value= @service.update(service_params)
      if value==false
        render(json: { success: false, message: "Service Already exists" }.to_json)

      else
        render(json: { success: true, message: "Service updated" }.to_json)

      end



    rescue Exception => exc
      @services=current_user.services.where(:is_deleted=>false)
      render(json: { success: false, message: "Fields cannot be blank" }.to_json)




    end
  end


  def getProfessionalsByMultipleSubServices

    time_start=Availability.unix_time_convert(params[:time_start])
    time_stop=Availability.unix_time_convert(params[:time_stop])

    begin
    all_users=[]
    users=[]
    reviews=[]

    sub_services=params[:services].collect{|service_id|ServiceSubCategory.find(service_id)}
    services=sub_services.collect{|sub| sub.services.where(:is_deleted=>false)}

    services.each do |service|
       users.push(service.map(&:user).uniq)
    end

    users.collect{|user| user.map{|user| all_users.push(user)}  }
    unique_users=all_users.uniq

    filtered_u=unique_users.collect{|user| Availability.getAvailedUser(user,time_start,time_stop)==true ? user : false}.reject{|av| av==false}
    #reviews=filtered_u.map{|stylist| Review.where(:stylist_id=>stylist.id)}.map{|review| review.first}
    #favourites=filtered_u.map{|stylist| FavouriteStylist.where(:stylist_id=>stylist.id)}.map{|review| review.first}
    #session[:]="mul"

    #reviews.collect{|reviews| reviews.map{|review| reviews.push(review)}  }
    getUsersListJson(filtered_u)

    rescue ActiveRecord::RecordNotFound
      not_found
    end


  end


  def index
    services = Service.all
    getServicesListJson(services)
  end

  def show
    getServiceJson(@service)
  end

  def create
      begin

          @service=current_user.services.new(service_params)
          @service.user_id=current_user.id
          @service.save
          render(json: { status: true, message: "service created successfully" }.to_json)



        rescue Exception => exc
      # do whatever you wish to warn the user, or log something

       render(json: {  status: false, message: exc.message}.to_json)

      end
  end



  def destroy
    begin
    service=Service.find(params[:id])
    service.update(:is_deleted=>true)
    @services=current_user.services.where(:is_deleted=>false)
    render(json: { success: true, message: "Service was successfully destroyed." }.to_json)
    rescue ActiveRecord::RecordNotFound
      render(json: { success: false, message: "Record not found" }.to_json)
    end
    end

  def servicesByUserId
    begin
      services = User.find(params[:user_id]).services.where(:is_deleted=>false)
      getServicesListJson(services)
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  protected



  def getServicesListJson(services)

    render(json:services,each_serializer: Api::V1::ServiceSerializer,root:'services')

  end

  def getUsersListJson(users)

    render(json:users,each_serializer: Api::V1::UserSerializer,:except=>[:city,:state,:zipcode,:address],root:'users')
  end

  def getServiceJson(service)
    render(json: Api::V1::ServiceSerializer.new(service).to_json)
  end
    
  def service_params
    params.require(:service).permit(:name, :amount, :user_id,:service_category_id ,:service_sub_category_id, :time,:description,:location1,:location2,:location3,:location4,:location5)
  end

  def set_service
    begin
      @service = Service.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  def auth_to_create!
    return (current_user.isStylist?) ? true : unauthenticated!
  end

  def modify_access!
    return current_user == @service.user ? true : unauthenticated!
  end

end
