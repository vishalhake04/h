class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #before_action :authenticate_user!
  #include Pundit
  protect_from_forgery with: :exception
  after_filter :store_location
  before_action :set_current_user

  def set_current_user
    User.current = current_user
  end
  def store_location
    session[:user_return_to] = request.fullpath
  end

  def after_sign_out_path_for(resource)
    cookies["myaccount"]=nil
     root_path
  end

  def after_sign_in_path_for(resource)
    if current_user.admin?
      dashboard_path
    else
      if session[:user_return_to].include?("errors") || session[:user_return_to].include?("confirm")
        root_path
      else
        if resource.isStylist? || cookies["myaccount"]=="logged_in"

          user_dashboard_path(resource)
        else

          if request.referrer.include?("help") ||  request.referrer.include?("how_it_works") || request.referrer.include?('/search')
             request.referrer
          else
              session[:user_return_to] || request.referrer || root_path
          end
          end
      end
    end

  end

  private
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  def help?
    !params[:action]=='help'
  end

end
