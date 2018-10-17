class Api::V1::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token
  prepend_before_filter :require_no_authentication, except:  [:create ,:facebook]
  respond_to :json
  def create

    build_resource(sign_up_params)
    resource.skip_confirmation!
    if resource.save
      sign_in resource

      json={ :success => true,
             info:  "Registered",
             :data => { :user => Api::V1::UserSerializer.new(resource),
                        :auth_token => current_user.authentication_token } }

      render :status => 200,
           :json =>json.to_json
    else
        render :status => :unprocessable_entity,
             :json => { :success => false,
                        :info => resource.errors.messages,
                        :data => {} }.to_json
    end
  end

  def facebook
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    provider=params[:facebook][:provider]
    uid=params[:facebook][:uid]
    email=params[:facebook][:info][:email]
    name=params[:facebook][:info][:name]
    role_id=params[:role_id]
    image=!params[:facebook][:info][:image].blank? ? params[:facebook][:info][:image] :nil
    gender= !params[:facebook][:info][:gender].blank? ? params[:facebook][:info][:gender] :nil
    phone= !params[:facebook][:info][:phone].blank? ? params[:facebook][:info][:phone] :nil

    @user = User.find_for_facebook_oauth(phone,gender,image,provider,uid,email,name,role_id,current_user)

    if @user.persisted?
      json={ :success => true,
             :info => "Logged In With Facebook",
             :data => { :user => Api::V1::UserSerializer.new(@user),
                        :auth_token => @user.authentication_token } }
      render :status => 200,
             :json => json.to_json
    else
      render :status => :unprocessable_entity,
             :json => { :success => false,
                        :info => @user.errors,
                        :data => {} }.to_json
    end
  end

  def google_oauth2

    provider=params[:google][:provider]
    uid=params[:google][:uid]
    email=params[:google][:info][:email]
    name=params[:google][:info][:name]
    role_id=params[:role_id]
    image=!params[:google][:info][:image].blank? ? params[:google][:info][:image] :nil
    gender= !params[:google][:info][:gender].blank? ? params[:google][:info][:gender] :nil
    phone= !params[:google][:info][:phone].blank? ? params[:google][:info][:phone] :nil


    @user = User.find_for_google_oauth2(phone,gender,image,provider,uid,email,name,role_id,current_user)

    if @user.persisted?
      json={ :success => true,
             :info => "Logged In With Google",
             :data => { :user => Api::V1::UserSerializer.new(@user),
                        :auth_token => @user.authentication_token } }
      render :status => 200,
             :json => json.to_json
    else
      render :status => :unprocessable_entity,
             :json => { :success => false,
                        :info => @user.errors,
                        :data => {} }.to_json
    end
  end
  
   def sign_up_params
    params.require(:user).permit(:role_id, :email, :password,:password_confirmation,:phone,:name,:first_name,:last_name,:gender,:apple_uuid,:address2)
  end
end
