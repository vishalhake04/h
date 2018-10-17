class HomeController < ApplicationController
 skip_after_filter :intercom_rails_auto_include,:only=>[:index]

  include HomeHelper
  protect_from_forgery except: :index
  #before_filter :read_notification
  #autocomplete :service_categories, :name
    def index

      if user_signed_in? && current_user.isStylist?
        redirect_to user_dashboard_path(current_user)

      else
        if  user_signed_in? && current_user.isAdmin?
          redirect_to dashboard_path
        else
        @alert = params[:alert] if !params[:alert].blank?
        @errors = params[:errors] if !params[:errors].blank?
        @confirmed = params[:confirm] if !params[:confirm].blank?
        #@services= Service.select(:name).uniq
        @availabilities = Availability::TIMEOBJ
        gon.service_names= getServiceNameList()
        @popular_services=PopularService.order(:id)
        @recently_booked=RecentlyBooked.order(:id)
        @featured_professional=FeaturedProfessional.order(:id)
        @instagram_images = Instagram.user_recent_media("257315215").take(6)





        # voucherify = Voucherify.new({
        #                                 "applicationId" => "c70a6f00-cf91-4756-9df5-47628850002b",
        #                                 "clientSecretKey" => "3266b9f8-e246-4f79-bdf0-833929b1380c"
        #                             })
        #
        # voucherify = Voucherify.new({"applicationId" => "4a21adeb-e28e-4dde-ad58-25a8eebe5a81",
        #                              "clientSecretKey" => "228708fd-611b-4172-9456-d4d7996ab5d0"
        #                             })
        # # voucherify.publish({campaign: "Redd2", channel: "Email", customer: "swapnil.b@consultadd.com"})
        #
        # voucherify.list({ limit: 10, skip: 20})
        #
        # ua             = Urbanairship
        # client         = Urbanairship::Client.new(key:"1hDk8co4QY29YWD7tWqGnA", secret:"TbTeIR7yRT--PhwS9nyU-g")
        # debugger
        # p              = client.create_push
        # p.audience     = Urbanairship.ios_channel('979D32652E8FF943DD027E4F635ABA02B46EE47D8D2EF1DC288AC7ED8FC020F3')
        # p.notification = Urbanairship.notification(ios: Urbanairship.ios(alert: "Hello Buddy"))
        # p.device_types = Urbanairship.device_types(["ios"])
        # p.send_push
        # Urbanairship.register_device '979D32652E8FF943DD027E4F635ABA02B46EE47D8D2EF1DC288AC7ED8FC020F3'
        # notifications=[ {
        #     :aps => {:alert => 'You have a new message!', :badge => 1}
        # }]
        # Urbanairship.push notification # => true


        voucherify = Voucherify.new({:applicationId => '997c141a-537e-4697-9c1c-d0969601051b', :clientSecretKey => '912ef6bf-029a-4e9d-ab8e-b1d55927ba7e'
                                            })






        #@booking=Booking.find(session[:booking_id]) if !session[:booking_id].blank?
        end
      end
     @messages=read_messages(current_user)



    end

  def inbox
    @messages=read_messages(current_user)
    @notifications=read_notification
    respond_to do |format|
      format.js { render :file => 'layouts/inbox_js.js.erb' }
    end


  end


  def help

  end





end
