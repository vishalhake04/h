  class Api::V1::UsersController < Api::V1::BaseController
  before_action :authenticate_user!, :except => [:get_uuid,:show,:create_message_client,:create_message_stylist]

  def sms

    begin
      session[:phone_number]=nil
      #@phone_number = User.find(params[:user][:id])
      pin=current_user.generate_pin
      response= current_user.send_pin(params[:user][:phone])
      session[:phone_number]=params[:user][:phone]
      response_edit=response.to_s
      @response=response_edit.split(" ").reject { |m| m == "'To'" }.join(" ")
      session[:url]=request.referer
      if response_edit.include? "not a valid"
        render(json: {success: true, message: @response}.to_json)
      else
        render(json: {success: false, message: @response}.to_json)
      end
    rescue ActiveRecord::RecordNotFound
      not_found
    end


    # respond_to do |format|
    #   format.js
    # end
  end



  def get_uuid

    begin
      user=User.find(params[:user_id])
      apple_uuid=params[:apple_uuid]
      user.update(:apple_uuid => apple_uuid)
      render(json: {success:true , message: "apple_uuid updated"}.to_json)
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  def update_password

    if current_user.update_with_password(user_params)
      #sign_in @user, :bypass => true
      render(json: {success: true, message: "Password updated"}.to_json)
    else

      render(json: {success: false, message: current_user.errors.full_messages[0]}.to_json)
    end
  end

  def update
   current_user.update(user_params)
   render(json: {success: true, user:Api::V1::UserSerializer.new(current_user,root:false)}.to_json)
  end

  def notification_settings
   if !current_user.notification_settings.blank?
      current_user.notification_settings.delete("notification_settings")
      current_user.notification_settings=params[:user]
      current_user.save
   else
     current_user.notification_settings=params[:user]
     current_user.save

   end
   render(json: {success:true}.to_json)

  end

  def get_settings_of_notifications
    noti_settings=current_user.notification_settings
    render(json: {success: true, notification_settings:!noti_settings.blank? ? noti_settings["notification_settings"]:nil}.to_json)

  end

  def user_info

      render(json: {success: true, user:Api::V1::UserSerializer.new(current_user,root:false)}.to_json)


  end

  def create_message_client
    client=User.find(params[:client_id])
    stylist=User.find(params[:stylist_id])
    message=params[:message]
    notification="#{{image:stylist.photo.image.url,sender_first_name:stylist.first_name,sender_last_name:stylist.last_name,message:message,created_at:Time.now.strftime('%d %b %Y %I:%S%p')}}"

    notifier_img=''
    # notifier_img = "<img src='#{stylist.photo.image.url}' style = 'height:35px;width:35px;'/>"
    # message=   "<li role ='presentation'><div class='media'><div class='pull-left'>#{notifier_img}</div>
    #                <div class='media-body'><h6 class='media-heading'><small><span style='text-color:blue;'>#{stylist.first_name.split(' ')[0]}</span><br/></small></h6><h6 class=media-heading><small><span>#{message}</span><br/></small></h6><h6 class='media-heading' style= 'margin-top:6px;'><small style='color:grey;'>#{Time.now.strftime('%d %b %Y %I:%S%p')}</small></h6></div></div></li>".html_safe.to_s
    notify_key ='reddera_messages' +"-" + client.id.to_s+'-'+client.created_at.to_s
    $redis.rpush(notify_key,notification)
    render(json: {success: true, notification: "notification sent"}.to_json)

  end

  def create_message_stylist

    client=User.find(params[:client_id])
    stylist=User.find(params[:stylist_id])
    message=params[:message]
    notification="#{{image:client.photo.image.url,sender_first_name:client.first_name,sender_last_name:client.last_name,message:message,created_at:Time.now.strftime('%d %b %Y %I:%S%p')}}"
    notify_key ='reddera_messages' +"-" + stylist.id.to_s+'-'+stylist.created_at.to_s
    $redis.rpush(notify_key,notification)
    render(json: {success: true, notification: "notification sent"}.to_json)

  end


  def read_messages

    notify_key_unread = 'reddera_messages' +"-" +current_user.id.to_s+"-"+current_user.created_at.to_s
    list_range_unread = $redis.llen(notify_key_unread)
    redis_messages = $redis.lrange(notify_key_unread,0,list_range_unread).reverse rescue []
    message_json=redis_messages.map{|message|  eval(message) }
    render(json: {success: true, notifications:message_json}.to_json)

  end

  def sms_verified
    begin
      #@user = User.find(params[:user][:id])
      if params[:user][:pin]==current_user.pin
        current_user.update(:verified_number => true, :phone => session[:phone_number])
        current_user.pin=params[:user][:pin]
        current_user.save
        render(json: {success: true, message: "Pin Verified"}.to_json)
      else
        render(json: {success: false, message: "Please check Your Pin"}.to_json)

      end
    rescue ActiveRecord::RecordNotFound
      not_found
    end
    #@message=params[:user][:pin].blank? ? User::PIN_BLANK_MESSAGE :User::INCORRECT_PIN_MESSAGE

    # redirect_to user_dashboard_path(current_user)
  end

  def user_params
    params[:user].permit(:bio,:stylist_type,:zipcode,:address2, :email,:current_password, :password, :password_confirmation, :phone , :name , :address,  :brand,  :description,:first_name,:last_name,:city,:state)
  end

end