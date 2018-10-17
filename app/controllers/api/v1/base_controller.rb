class Api::V1::BaseController < ApplicationController
  protect_from_forgery with: :null_session

  before_action :destroy_session
 # before_filter :set_current_user

  def authenticate_user!

    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)

    user_email = options.blank?? nil : options[:email]
    user = user_email && User.find_by(email: user_email)

    if user && ActiveSupport::SecurityUtils.secure_compare(user.authentication_token, token)
      @current_user = user
      set_current_user
    else
      return unauthenticated!
    end
  end

  def set_current_user
    User.current = current_user
  end

  def unauthenticated!
    render( json: {errors:"Unauthorized Access"}.to_json  )
  end

  def destroy_session
    request.session_options[:skip] = true
  end

  def not_found
    render(json: {status: 404, errors: 'Not found'}.to_json)
  end

end
