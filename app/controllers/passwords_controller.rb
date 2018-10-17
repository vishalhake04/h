class PasswordsController < Devise::PasswordsController
  skip_after_filter :intercom_rails_auto_include

  def after_sending_reset_password_instructions_path_for(resource_name)

    root_path(:confirm=>"we have send an link to change password please check your email")
  end
  def after_resetting_password_path_for(resource)
    root_path(:confirm=>"Password updated")

  end

  def create


    user=User.find_by_email(params[:user][:email])

    if !user.blank? && !user.confirmed_at.blank?
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message(:notice, :send_instructions) if is_navigational_format?
      respond_with resource, :location => after_sending_reset_password_instructions_path_for(resource_name)
    else

      # Redirect to custom page instead of displaying errors
      redirect_to root_path(:confirm=>"email"+" "+resource.errors.messages[:email][0])

      # respond_with_navigational(resource){ render_with_scope :new }

    end
    else
      redirect_to root_path(:confirm=>"user not found")

    end


  end
end