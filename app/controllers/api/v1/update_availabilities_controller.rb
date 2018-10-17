class Api::V1::UpdateAvailabilitiesController <  Api::V1::BaseController
 before_action :authenticate_user!

 def create
  u_available = current_user.update_availabilities.first
  u_available = UpdateAvailability.new if u_available.blank?
  u_available.update_availability(params)
  @update_unvail_allDay=current_user.update_availabilities.first.date_time if !current_user.update_availabilities.blank?
  render(json: {sub_services:{status: 404, errors: 'Not found'}}.to_json)


 end


 def delete_unavail

  UpdateAvailability.delete_all_day_date(params,current_user)
  @update_unvail_allDay=current_user.update_availabilities.first.date_time if !current_user.update_availabilities.blank?
  respond_to do |format|
   format.js { render :file => 'availabilities/avail.js.erb' }

  end
  #render js: "window.location = '#{user_availabilities_path(current_user.id)}';"
 end
end


