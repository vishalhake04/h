class UsersController < ApplicationController
  skip_after_filter :intercom_rails_auto_include
  before_action :set_user, only: [ :edit, :update, :destroy]
  #before_action :authenticate_user!, :except => [:stylist_new, :client_new, :create, :show]

  def stylist_profile

    @user=User.find(params[:id])
    @services = @user.services.where(:is_deleted=>false)
    @reviews=Review.select{|review| review.stylist_id == @user.id}
    @previous_works = @user.previous_works.where(is_additional:false)

  end

  def show

    if current_user.isAdmin?
      redirect_to dashboard_path
    else
      redirect_to user_dashboard_path(current_user)

    end
  end

  def autocomplete

    users=User.all.map(&:first_name)

    render(json: users)
  end

  def sms_verified
   

    @user = User.find(params[:user][:id])
    if params[:user][:pin]==@user.pin
      @user.update(:verified_number=>true,:phone=>session[:phone_number])
      @user.pin=params[:user][:pin]
      @user.save
      if request.referer.include?'/transactions/new'
         render :js => "window.location = '/transactions/new'" if request.referer.include?'/transactions/new'
      else
        respond_to do |format|
          format.js
        end
      end
     #@message=params[:user][:pin].blank? ? User::PIN_BLANK_MESSAGE :User::INCORRECT_PIN_MESSAGE
    else

    respond_to do |format|
      format.js
    end
    end
   # redirect_to user_dashboard_path(current_user)
  end

  def sms

    session[:phone_number]=nil
    @phone_number = User.find(params[:user][:id])
    pin=@phone_number.generate_pin
    response= @phone_number.send_pin(params[:user][:phone])
    session[:phone_number]=params[:user][:phone]
    response_edit=response.to_s
    @response=response_edit.split(" ").reject{|m| m == "'To'"}.join(" ")
    session[:url]=request.referer


    respond_to do |format|
      format.js
    end
  end

  def dashboard

    @user=User.find(params[:user_id])
    if current_user.isStylist?
    @booking_history={}
     #@transactions=Transaction.where(:user_id=>current_user.id,:is_deleted=>false)
      #transaction=Transaction.where(:stylist_id=> current_user.id,:is_deleted=>false,:transaction_status=>"submitted_for_settlement")
      bookings=Booking.where(:stylist_id => current_user.id,:is_confirmed => true)
      bookings_for_earnings=Booking.where(:stylist_id => current_user.id)
    @total_earnings_till_date=Transaction.total_earnings_till_date(bookings_for_earnings)
     # bookings_uptil_date=bookings_for_earnings.select{|booking| booking.dates.between?(Date.today.beginning_of_month,Date.yesterday) }
      bookings_current_month=bookings_for_earnings.select{|booking| booking.dates.between?(Date.today.beginning_of_month,Date.today.end_of_month ) }


      @my_earnings=Transaction.my_earnings(bookings_current_month,@total_earnings_till_date)

      bookings= Booking.where(:stylist_id=>@user.id)
     pendings=bookings.select{|booking| Booking.bookedDateTime(booking) >= DateTime.now && booking.status==Booking::PENDING  }
     upcomings=bookings.select{|booking|   Booking.bookedDateTime(booking) >= DateTime.now  && booking.status==Booking::UPCOMING}
    past=bookings.select{|booking|  booking.status==Booking::PAST}

    @past=past.to_a.take(5)if !past.blank?
    @pendings=pendings.to_a.take(5)if !pendings.blank?
    @upcomings=upcomings.to_a.take(5)if !upcomings.blank?
    upcomings_count=upcomings.to_a.count

    @requests= pendings.to_a.count + upcomings_count + past.count
    @appointments=past.count + upcomings_count
    else
      pendings=@user.bookings.select{|booking| Booking.bookedDateTime(booking) >= DateTime.now && booking.status==Booking::PENDING  }
      upcomings=@user.bookings.select{|booking|   Booking.bookedDateTime(booking) >= DateTime.now  && booking.status==Booking::UPCOMING}
      past=@user.bookings.select{|booking|  booking.status==Booking::PAST}

      @pendings=pendings.to_a.take(3)if !pendings.blank?
      @upcomings=upcomings.to_a.take(5)if !upcomings.blank?
      past=past.to_a.take(5)if !past.blank?
    end
    session[:booking_id]=nil

  end


  def stylist_login

  end

  def card_destroy
    result = Braintree::PaymentMethod.delete(params[:token_value])
    redirect_to edit_user_path(current_user)

  end

  def edit

    @user = current_user
    @alert=params[:alert][0] if !params[:alert].blank?
    @confirmed=params[:confirmed] if !params[:confirmed].blank?

    collection = Braintree::Customer.search do |search|
      search.id.is current_user.braintree_customer_id
    end

  @cards=collection.first.credit_cards


  end
 def create_message
   user=User.find(params[:user_id])
   message=params[:message]
   notifier_img=current_user.photo.image.url
   notification="#{{image:notifier_img,messaged_person_name:current_user.first_name+" "+current_user.last_name,message:message,created_at:Time.now.strftime('%d %b %Y %I:%S%p')}}"

   # notifier_img = "<img src='#{current_user.photo.image.url}' style = 'height:35px;width:35px;'/>"
   # message=    notification = "<li role ='presentation'><div class='media'><div class='pull-left'>#{notifier_img}</div>
   #                 <div class='media-body'><h6 class='media-heading'><small><span style='text-color:blue;'>#{current_user.first_name.split(' ')[0]}</span><br/></small></h6><h6 class=media-heading><small><span>#{message}</span><br/></small></h6><h6 class='media-heading' style= 'margin-top:6px;'><small style='color:grey;'>#{Time.now.strftime('%d %b %Y %I:%S%p')}</small></h6></div></div></li>".html_safe.to_s
   notify_key ='reddera_messages' +"-" + user.id.to_s+'-'+user.created_at.to_s
   Message.create_message_record(message,user.id,current_user.id)
   $redis.rpush(notify_key,notification)
   redirect_to stylist_path(user.id,user.first_name)

 end

  def client_profile
    @portfolio=[]
    @user=User.find_by_first_name(params[:name].split('.')[0])
    booking=Booking.where(:user_id=>@user.id,:status=>Booking::UPCOMING,:is_confirmed=>true,:is_deleted=>false)
    @booking_size= !booking.blank? ?  booking.size() : 0
    user=User.where(:role_id=>Role::STYLIST)
    @instagram_images = Instagram.user_recent_media("257315215")
    #user.each{|user|@portfolio.push(user.previous_works.where(:is_additional=>false))}
    i=0
    while i < @instagram_images.size
      @portfolio.push(@instagram_images.shift(5))
    end

  end


  def update_password

    @user = User.find(current_user.id)

    if @user.update_with_password(user_params)
      sign_in @user, :bypass => true
      redirect_to edit_user_path(current_user.id,:confirmed=>"Password Updated")
    else

      redirect_to edit_user_path(current_user.id,:alert=>@user.errors.full_messages)
    end
  end

  def update

    respond_to do |format|

      if @user.update(user_params)
        @user.update(:verified_number=>false) if !params[:user][:phone].blank?
		  @user.photo.update_attribute(:image,params[:file]) if !params[:file].blank?
      if params[:user][:from_transaction]=="true"

        format.html { redirect_to new_transaction_path, notice: 'User was successfully updated.' }
      else
        format.html { redirect_to user_dashboard_path(@user), notice: 'User was successfully updated.' }
      end

      format.json { render :stylist_profile, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def complaint_email

    details={:complaints=>[params[:complaint1],params[:complaint2],params[:complaint3],params[:complaint4]].reject{|a| a==nil},
             :information=>{:name=>params[:name],:company=>params[:company],:email=>params[:email],:phone=>params[:phone]},
            :complaint_details=>params[:details]}

    UserMailer.complaint(details).deliver
   redirect_to help_path
  end

  def inquiry_email

    details={:complaints=>[params[:inquiry1],params[:inquiry2],params[:inquiry3],params[:inquiry4]].reject{|a| a==nil},
             :information=>{:name=>params[:name],:company=>params[:company],:email=>params[:email],:phone=>params[:phone]},
             :complaint_details=>params[:details]}

    UserMailer.inquiry(details).deliver
    redirect_to help_path

  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

=begin

  def generate_client_token
    if current_user.has_payment_info?
      Braintree::ClientToken.generate(customer_id: current_user.braintree_customer_id)
    else

      Braintree::ClientToken.generate
    end
  end
=end


  private
  def set_user
    @user = User.find(params[:id])
  end

    def user_params
      params[:user].permit(:bio,:stylist_type,:zipcode, :email,:current_password, :password, :password_confirmation, :phone , :name , :address,  :brand,  :description,:first_name,:last_name,:city,:state)
    end
end
