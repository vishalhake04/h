class Service < ActiveRecord::Base
  require 'date'
  serialize :location, JSON
  #validates_presence_of  :amount,:description
  #validates_uniqueness_of :service_category_id,:service_sub_category_id,:amount,:time

  validates :amount, :uniqueness => {:scope => [:time, :service_category_id,:service_sub_category_id]},if: :check_status
  belongs_to :user
  has_many :bookings,:dependent => :destroy
  has_many :votes, :as => :votable
  has_many :reviews
  belongs_to :service_category
  belongs_to :service_sub_category
  has_one :photo, :as => :imageable,:dependent => :destroy
  searchable do
    text :service_categories do
      service_category.name
    end

    text :service_sub_category do
      service_sub_category.name
    end
    string :location1
    string :location2
    string :location3
    string :location4
    string :location5
    boolean :is_deleted
  end
  # handle_asynchronously :solr_index
  # handle_asynchronously :remove_from_index
  LOCATIONS =['Jersey City','Broklyn','Manhattan','Bronx']



  def check_status

    if is_deleted == true
      return false
    else
      user.services.where(:service_category_id=>self.service_category_id,:service_sub_category_id=>self.service_sub_category_id,:is_deleted=>false,:amount=>self.amount,:time=>self.time).exists? ? true:false
    end
  end

  def self.filter_services(params)
    location=params[:location].capitalize
    services =Service.all

    #params[:name].split('(')[1].remove(')').to_s
    searchText = !params[:name].blank? ? check_name(params[:name]) : " "
    #searchText += !params[:location].blank? ? params[:location].to_s : ""

    search = services.search do
      fulltext searchText
      if !params[:location].blank?
        any_of do
          with(:location1,location)
          with(:location2,location)
          with(:location3,location)
          with(:location4,location)
          with(:location5,location)
        end
      end

      all_of do
        with(:is_deleted,false)
      end
    end
    location=params[:location].capitalize
    services = search.results.uniq

    # if !params[:location].blank?
    #   services=services.select{|service|(service.location1==location||service.location2==location||service.location3==location ||service.location4==location||service.location5==location) && service.is_deleted==false}
    #
    # end
    return services_by_datetime(services,params)
  end

  def self.check_name(name)

   return name.include?('(') ?  name.split('(')[1].remove(')').to_s : name
  end

  def self.services_by_datetime(services,params)
    gservices=[]

    date =  params[:date].blank? ? Date.today : Date.parse(params[:date])

    day=(date.strftime('%a')).downcase

    services.each do |service|
      isAvail=false

      update_availabilities=service.user.update_availabilities.first

      if match_date_with_update_avail(update_availabilities,getTimeArray(params[:time]),date)
        gservices.push(service)
      else
        if params[:time].blank?
          isAvail = service.user.availabilities.map(&:"#{day}").include? true
        else
          isAvail = service.user.availabilities.where("time IN (?)", getTimeArray(params[:time])).map(&:"#{day}").include? true
        end

        gservices.push(service) if isAvail
      end
    end
    return gservices
    end


    def self.match_date_with_update_avail(u_avail_obj,time_slots,date)

     # u_avail_obj=user.update_availabilities.first
      if u_avail_obj.blank?
        return false
      else
        a_exist = u_avail_obj.date_time.find{|av| av["date"] == date.to_s}
        if a_exist.blank?
           return false
        else
          if a_exist["time"].blank?
           return true
          else
#pura loop chalane ki zaroorat nahi hai

            check_time=time_slots.map{|time| a_exist["time"].include?(time)}.include?(true)
            is_Avail=check_time==true ?  true:false
            return is_Avail
          end

        end

        #return is_Avail
      end
      #u_avail_obj.date_time.delete(a_exist)
    end

  def self.getTimeArray(timeStr)

    time= timeStr.split(',')
    return time.collect(&:strip)

  end

  def self.getServiceByName(params)
    service=Service.find(params[:id])
    service_name="#{service.service_category.name}(#{service.service_sub_category.name})"
    services =Service.all
    searchText = !service_name.blank? ? service_name: " "
    search = services.search do
      fulltext searchText
      all_of do
        with(:is_deleted,false)
      end
    end
    return search.results
  end



  def self.getServiceNameList

    services=Service.all
    services_name=services.collect{|service| "#{service.service_category.name}(#{service.service_sub_category.name})"}.uniq
    return services_name
  end
  def self.getUpdatedavailabilities(update_availabilities,time_slots,date)


     if update_availabilities.blank?
       return false
     else

       a_exist = update_availabilities.date_time.find{|av| av["date"] == date.to_s}
       a_exist = update_availabilities.date_time.find{|av| av["date"] == date.to_s}
       check_time=time_slots.map{|time| a_exist["time"].include?(time)}.include?(true)
        is_Avail=check_time==true ?  true:false
       return is_Avail
     end
    # time_slots.each do|time|
    #
    #   return true if update_availabilities.where("'#{time}' = ANY (time)").map(&:date).include? date
    #   return false
    # end


  end
end