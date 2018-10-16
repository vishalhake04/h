module HomeHelper

  def parse_error(errors)
    error_msg = ""
    errors.each_with_index do |e,index|
      error_msg += e[0] + " " + e[1][0]
      error_msg += "  , " if index < errors.size-1
    end
    return error_msg;
  end

  def create_message_booking(message,booking)

    notifier_img=''
    notifier_img = "<img src='#{booking.user.photo.image.url}' style = 'height:35px;width:35px;'/>"
     notification="#{{image:booking.user.photo.image.url,sent_person_name:booking.user.first_name+" "+booking.user.last_name,message:message,created_at:Time.now.strftime('%d %b %Y %I:%S%p')}}"

    # notification = "<li role ='presentation'><div class='media'><div class='pull-left'>#{notifier_img}</div>
     #               <div class='media-body'><h6 class='media-heading'><small><span style='text-color:blue;'>#{booking.user.first_name.split(' ')[0]}</span><br/></small></h6><h6 class=media-heading><small><span>#{message}</span><br/></small></h6><h6 class='media-heading' style= 'margin-top:6px;'><small style='color:grey;'>#{Time.now.strftime('%d %b %Y %I:%S%p')}</small></h6></div></div></li>".html_safe.to_s
    notify_key ='reddera_messages' +"-" + booking.stylist.id.to_s+'-'+booking.stylist.created_at.to_s
    $redis.rpush(notify_key,notification)
    Notification.create_notification_record(message,booking.id,booking.user.id,booking.stylist.id)
  end



  def create_message(user,client,message)

  end

  def getServiceNameList

    service_sub_cat=ServiceSubCategory.all
    services_name=service_sub_cat.map{|sub_service| "#{sub_service.name} - #{sub_service.service_category.name}"}.uniq

    return services_name

  end

  def getInstaImages(insta_images)
    return insta_images.collect{|instagram| instagram.images.first[1].url}.join(',')

  end


def getInstaCaption(insta_images)
  return insta_images.collect{|instagram| instagram.caption.text}.join(',')

end

  def read_messages(user)

    #notify_key_unread = 'reddera_message_stylist' +"-" +user.id.to_s+"-"+user.created_at.to_s
    if !current_user.blank?

      notify_key_unread = 'reddera_messages' +"-" +user.id.to_s+"-"+user.created_at.to_s

      #notify_key_read = 'bloggerlive_notify_read' + current_user.id.to_s

      begin

        list_range_unread = $redis.llen(notify_key_unread)
        @redis_messages = $redis.lrange(notify_key_unread,0,list_range_unread).reverse rescue []
        @redis_messages.map{|message|  eval(message) }
      rescue

      end
      #list_range_read= $redis.llen(notify_key_read)
      #@redis_notifications_unread = $redis.lrange(notify_key_unread,0,list_range_unread).reverse rescue []
      #@redis_notifications = @redis_notifications_unread + @redis_notifications_read

    end
  end


  def create_notification_client(booking,user,purpose)

    notification = ''
    notify_key = ''
    message="Booking for service #{Booking.get_services_name_by_booking(booking)} for #{booking.slots.slice(0,7)} is #{purpose}"
    # notifier_img = "<img src='#{booking.stylist.photo.image.url}' style = 'height:35px;width:35px;'/>"
    notification="#{{image:booking.stylist.photo.image.url,sent_person_name:booking.stylist.first_name+" "+booking.stylist.last_name,message:message,created_at:Time.now.strftime('%d %b %Y %I:%S%p')}}"
    # notification = "<li role ='presentation'><div class='media'><div class='pull-left'>#{notifier_img}</div>
    #                <div class='media-body'><h6 class='media-heading'><small><span style='text-color:blue;'>#{booking.stylist.first_name.split(' ')[0]} has #{purpose}</span><br/></small></h6><h6 class=media-heading><small><span>Booking for service #{Booking.get_services_name_by_booking(booking)} for #{booking.slots.slice(0,7)}</span><br/></small></h6><h6 class='media-heading' style= 'margin-top:6px;'><small style='color:grey;'>#{Time.now.strftime('%d %b %Y %I:%S%p')}</small></h6></div></div></li>".html_safe.to_s

    Notification.create_notification_record(message,booking.id,booking.user.id,booking.stylist.id)


    notify_key ='reddera_notify_unread' +"-" +user.id.to_s+"-"+user.created_at.to_s
    $redis.rpush(notify_key,notification)


  end

 def create_notification_stylist(booking,user,purpose)
  notification = ''
  notify_key = ''
  message="Booking for service #{Booking.get_services_name_by_booking(booking)} for #{booking.slots.slice(0,7)} is #{purpose}"
  notification="#{{image:booking.user.photo.image.url,sent_person_name:booking.user.first_name+" "+booking.user.last_name,message:message,created_at:Time.now.strftime('%d %b %Y %I:%S%p')}}"
  # notifier_img = "<img src='#{booking.user.photo.image.url}' style = 'height:35px;width:35px;'/>"
  # notification = "<li role ='presentation'><div class='media'><div class='pull-left'>#{notifier_img}</div>
  #                  <div class='media-body'><h6 class='media-heading'><small><span style='text-color:blue;'>#{booking.user.first_name.split(' ')[0]} has #{purpose}</span><br/></small></h6><h6 class=media-heading><small><span>Booking for service #{Booking.get_services_name_by_booking(booking)} for #{booking.slots.slice(0,7)}</span><br/></small></h6><h6 class='media-heading' style= 'margin-top:6px;'><small style='color:grey;'>#{Time.now.strftime('%d %b %Y %I:%S%p')}</small></h6></div></div></li>".html_safe.to_s

  Notification.create_notification_record(message,booking.id,booking.user.id,booking.stylist.id)

  notify_key ='reddera_notify_unread' +"-" +user.id.to_s+"-"+user.created_at.to_s

  $redis.rpush(notify_key,notification)
  end

  def create_notification_reschedule_stylist(booking,stylist,dates,slots)

    notification = ''
    notify_key = ''
    message="Booking for service #{Booking.get_services_name_by_booking(booking)} at #{booking.slots.slice(0,7)}  has been rescheduled to to #{dates.to_date.strftime("%a-%b. %d %Y")} #{slots.slice(0,7)} please confirm the pending appointment"

    notification="#{{image:booking.user.photo.image.url,sent_person_name:booking.user.first_name+" "+booking.user.last_name,message:message,created_at:Time.now.strftime('%d %b %Y %I:%S%p')}}"

    # notifier_img = "<img src='#{booking.user.photo.image.url}' style = 'height:35px;width:35px;'/>"
   #  notification = "<li role ='presentation'><div class='media'><div class='pull-left'>#{notifier_img}</div>
   #                 <div class='media-body'><h6 class='media-heading'><small><span style='text-color:blue;'>#{booking.user.first_name.split(' ')[0]} has #{purpose}</span><br/></small></h6><h6 class=media-heading><small><span>Booking for service #{Booking.get_services_name_by_booking(booking)}   to #{booking.dates.strftime("%a-%b. %d %Y")} #{current_booking.slots.slice(0,7)} please confirm the pending appointment</span><br/></small></h6><h6 class='media-heading' style= 'margin-top:6px;'><small style='color:grey;'>#{Time.now.strftime('%d %b %Y %I:%S%p')}</small></h6></div></div></li>".html_safe.to_s
   message=
    # notification="#{{image:user.photo.image.url,sent_person_name:booking.user.first_name,message:message,created_at:Time.now.strftime('%d %b %Y %I:%S%p')}}"

    notify_key ='reddera_notify_unread'+"-" +stylist.id.to_s+"-"+stylist.created_at.to_s

    $redis.rpush(notify_key,notification)
    Notification.create_notification_record(message,booking.id,booking.user.id,booking.stylist.id)

  end

  def create_notification_reschedule_client(booking,user,purpose)

    notification = ''
    notify_key = ''
    message="Booking for service #{Booking.get_services_name_by_booking(booking)} has been rescheduled please confirm one of the two optional times"
    notification="#{{image:booking.user.photo.image.url,sent_person_name:booking.user.first_name+" "+booking.user.last_name,message:message,created_at:Time.now.strftime('%d %b %Y %I:%S%p')}}"


    notifier_img = "<img src='#{booking.stylist.photo.image.url}' style = 'height:35px;width:35px;'/>"
    # notification = "<li role ='presentation'><div class='media'><div class='pull-left'>#{notifier_img}</div>
    #                <div class='media-body'><h6 class='media-heading'><small><span style='text-color:blue;'>#{booking.stylist.first_name.split(' ')[0]} has #{purpose}</span><br/></small></h6><h6 class=media-heading><small><span>Booking for service #{Booking.get_services_name_by_booking(booking)} and provided two optional times please confirm one of the timings to book your appointment</span><br/></small></h6><h6 class='media-heading' style= 'margin-top:6px;'><small style='color:grey;'>#{Time.now.strftime('%d %b %Y %I:%S%p')}</small></h6></div></div></li>".html_safe.to_s


    notify_key ='reddera_notify_unread'+"-" +user.id.to_s+"-"+user.created_at.to_s
    Notification.create_notification_record(message,booking.id,booking.user.id,booking.stylist.id)

    $redis.rpush(notify_key,notification)
  end


  def client_confirm_reschedule(booking,user,status)
    notification = ''
    notify_key = ''
    message="Rescheduled request for service #{Booking.get_services_name_by_booking(booking)} is accepted"
    notification="#{{image:booking.user.photo.image.url,sent_person_name:booking.user.first_name+" "+booking.user.last_name,message:message,created_at:Time.now.strftime('%d %b %Y %I:%S%p')}}"

    notifier_img = "<img src='#{booking.user.photo.image.url}' style = 'height:35px;width:35px;'/>"
    # notification = "<li role ='presentation'><div class='media'><div class='pull-left'>#{notifier_img}</div>
    #                <div class='media-body'><h6 class='media-heading'><small><span style='text-color:blue;'>#{booking.user.first_name.split(' ')[0]} has accepted Reschedule Request for #{Booking.get_services_name_by_booking(booking)} at </span><br/></small></h6><h6 class=media-heading><small><span> #{booking.dates.strftime("%a-%b. %d %Y")} #{booking.slots.slice(0,7)} </span><br/></small></h6><h6 class='media-heading' style= 'margin-top:6px;'><small style='color:grey;'>#{Time.now.strftime('%d %b %Y %I:%S%p')}</small></h6></div></div></li>".html_safe.to_s


    notify_key ='reddera_notify_unread' +"-" +user.id.to_s+"-"+user.created_at.to_s
    Notification.create_notification_record(message,booking.id,booking.user.id,booking.stylist.id)

    $redis.rpush(notify_key,notification)

  end

  def read_notification

    if !current_user.blank?
    notify_key_unread = 'reddera_notify_unread' +"-" +current_user.id.to_s+"-"+current_user.created_at.to_s

    #notify_key_read = 'bloggerlive_notify_read' + current_user.id.to_s

    begin

        list_range_unread = $redis.llen(notify_key_unread)
          @redis_notifications_unread = $redis.lrange(notify_key_unread,0,list_range_unread).reverse rescue []
        @redis_notifications_unread.map{|message|  eval(message) }

    rescue

    end
      #list_range_read= $redis.llen(notify_key_read)
      # @redis_notifications_unread = $redis.lrange(notify_key_unread,0,list_range_unread).reverse rescue []
      #@redis_notifications = @redis_notifications_unread + @redis_notifications_read

    end

    end


end
