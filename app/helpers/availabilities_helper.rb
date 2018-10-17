module AvailabilitiesHelper
  def availabilitiesWithSLots(current_user)
    @availability=current_user.availabilities

     return @availability

  end

end