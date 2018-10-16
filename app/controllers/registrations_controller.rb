class RegistrationsController < Devise::RegistrationsController
  skip_after_filter :intercom_rails_auto_include
  def after_inactive_sign_up_path_for(resource_or_scope)
     root_path(:confirm=>"Check your email We have send an email Tap the link in the email to confirm it’s you")
  end

  def after_sign_up_fail_path_for(resource)
    redirect_to root_path(:errors => resource.errors.messages)
  end
  # POST /resource
  def create
    build_resource(sign_up_params)
    resource.skip_confirmation!
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        #set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        #set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      after_sign_up_fail_path_for(resource)
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:role_id, :email, :password,:password_confirmation,:phone, :name,:first_name,:last_name,:stylist_type)
  end

end
