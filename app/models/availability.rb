class Availability < ActiveRecord::Base
  belongs_to  :user,dependent: :destroy

  TIMEOBJ =[
      ["Early Morning (6am-8am)", "06AM, 07AM, 08AM"],
      ["Morning (9am-11am)","09AM, 10AM, 11AM"],
      ["Afternoon (12pm-4pm)", "12PM, 01PM, 02PM, 03PM, 04PM"],
      ["Evening (5pm-8pm)", "05PM, 06PM, 07PM, 08PM"],
      ["Late Night (9pm-11pm)", "09PM, 10PM, 11PM"]
  ]

  TIME_SLOTS=[["06AM", "07AM", "08AM"],["09AM","10AM","11AM"],["12PM","01PM","02PM","03PM","04PM"],["05PM","06PM","07PM","08PM"],["09PM","10PM","11PM"]]

  def self.getAvailedUser(user,time_start,time_stop)

    date =  Date.today
    day=(date.strftime('%a')).downcase
    slots=Availability::TIME_SLOTS.collect{|slots| slots.include?(time_start) || slots.include?(time_stop) ? slots : false}.reject{|av| av==false}
    u_avail=user.availabilities.where("time IN (?)", slots[0]).map(&:"#{day}").include? true

    return u_avail==true ? true :false
  end

  def self.unix_time_convert(time)
    date_time=DateTime.parse(time)
    first_time=date_time.to_s(:time).split(':')[0]
    time=Time.parse("#{first_time}:00").strftime("%l %P").upcase.split(" ")[0]
    am_or_pm=Time.parse("#{first_time}:00").strftime("%l %P").upcase.split(" ")[1]
    return format('%02d',time)+"#{am_or_pm}"
  end

  def self.update_availabilities(availabilities)


    availabilities.each_with_index do |av,index|
      av_obj = av[1].blank? ? av : av[1]

      avail = Availability.find(av_obj['id'])
      avail.mon = !av_obj['mon'].blank? ? true : false
      avail.tue = !av_obj['tue'].blank? ? true : false
      avail.wed = !av_obj['wed'].blank? ? true : false
      avail.thu = !av_obj['thu'].blank? ? true : false
      avail.fri = !av_obj['fri'].blank? ? true : false
      avail.sat = !av_obj['sat'].blank? ? true : false
      avail.sun = !av_obj['sun'].blank? ? true : false
      avail.update_attributes(:mon=>avail.mon,:tue=>avail.tue,:wed=>avail.wed,:thu=>avail.thu,:fri=>avail.fri,:sat=>avail.sat,:sun=>avail.sun)
    end
  end
end
