class UpdateAvailability < ActiveRecord::Base
  belongs_to :user

  def update_availability(params)
    p_dates = getJsonArray(params[:dates])

    if !self.id.blank?
      p_dates.each do |dt|
        a_exist = self.date_time.find{|av| av["date"] == dt["date"]}
        if a_exist.blank?
          append_avail(dt)
        else
          append_time(a_exist, dt)
        end
      end
    else
      self.date_time=p_dates
      self.user_id=params[:user_id]
      self.save
    end
  end

  def self.delete_all_day_date(params,current_user)
    u_avail_obj=current_user.update_availabilities.first
    a_exist = u_avail_obj.date_time.find{|av| av["date"] == params[:date]}
    u_avail_obj.date_time.delete(a_exist)
    u_avail_obj.update(:date_time=>u_avail_obj.date_time)

  end

  private

  def append_avail(dObj)
    dArry = self.date_time
    self.update_attribute(:date_time, dArry.push(dObj))
  end

  def append_time(a_exist, dObj)
    dArry = self.date_time
    dArry.delete(a_exist)
    self.update_attribute(:date_time, dArry.push(dObj))
  end

  def getJsonArray(dHash)
    dArry=[]
    dHash.each_with_index {|h,i| dArry.push(h[1]) }
    return dArry.uniq
  end

end
