class AvailabilitiesController < ApplicationController
  skip_after_filter :intercom_rails_auto_include
  before_action :authenticate_user!

  def index
    @availabilities=[]

    pm=current_user.availabilities.where("time like ?", "%#{"PM"}%")
    am=current_user.availabilities.where("time like ?", "%#{"AM"}%")
    sortedAM=am.sort{ |a, b|  a.time <=> b.time }
    sortedPM=pm.sort{ |a, b|  a.time <=> b.time }
    sortedAM.each { |avail|  @availabilities.push(avail)}
    sortedPM.each { |avail|  @availabilities.push(avail)}

    @confirmed=params[:confirm] if !params[:confirm].blank?
    working_hours_current_week = current_user.availabilities. map{|p| [p.mon,p.tue,p.wed,p.thu,p.fri,p.sat,p.sun]}.flatten.count(true)
    @expected_income_current_week = working_hours_current_week * 50
    @update_unvail_allDay=current_user.update_availabilities.first.date_time if !current_user.update_availabilities.blank?
    #@update_alter=current_user.update_availabilities.where(:is_not_available=>false).first.date_time if !current_user.update_availabilities.where(:is_not_available=>false).blank?


  end

  def update_availabilities
    availabilities = params[:avaliabilties]
    Availability.update_availabilities(availabilities)
    flash[:notice] = "Updated Availability!"
    redirect_to user_availabilities_path(:confirm => "Your schedule has been updated")
  end

  private

  def availability_params
    params[:availability].permit(:user_id, :mon, :tue, :time, :wed, :thu, :fri, :sat, :sun)
  end

end
