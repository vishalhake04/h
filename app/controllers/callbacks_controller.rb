class CallbacksController < Devise::OmniauthCallbacksController
  skip_after_filter :intercom_rails_auto_include
  
  def facebook

    # You need to implement the method below in your model (e.g. app/models/user.rb)
    auth=request.env["omniauth.auth"]
    provider=auth.provider
    uid=auth.uid
    email=auth.info.email
        name=auth.extra.raw_info.name
    image= !auth.info.image.blank? ? auth.info.image : nil
    gender=nil
    phone=nil

    #
    @user = User.find_for_facebook_oauth(phone,gender,image,provider, uid, email, name, request.env["omniauth.params"]["role_id"], current_user)

    if @user.nil?
      redirect_to root_url(:confirm => "Please Register to Login!")
    else
      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      else
        session["devise.facebook_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end

  def google_oauth2
    auth=request.env["omniauth.auth"]
    provider=auth.provider
    uid=auth.uid
    email=auth.info.email
      name=auth.extra.raw_info.name
    image= !auth.info.image.blank? ? auth.info.image : nil
    gender=nil
    phone=nil

    @user = User.find_for_google_oauth2(phone,gender,image,provider, uid, email, name, request.env["omniauth.params"]["role_id"], current_user)
    if @user.class==String
      redirect_to root_url(:confirm => @user)
    else
      if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        sign_in_and_redirect @user, :event => :authentication
      else
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
    end
  end




end