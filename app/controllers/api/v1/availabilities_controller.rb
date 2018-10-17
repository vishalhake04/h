class Api::V1::AvailabilitiesController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :auth_to_update!
  skip_before_action :verify_authenticity_token

  def update_availabilities
    availabilities = params[:avaliabilties]
    Availability.update_availabilities(availabilities)
    render(json:{sucess: true, message: 'Availabilities is successfully updated.' }.to_json)
  end

  def index

    render json:current_user.availabilities,
           each_serializer: Api::V1::AvailabilitySerializer,root: 'availabilities'

  end

  def auth_to_update!

    return (current_user.isStylist?) ? true : unauthenticated!
  end

end
