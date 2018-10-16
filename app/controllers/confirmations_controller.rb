class ConfirmationsController < Devise::ConfirmationsController
  skip_after_filter :intercom_rails_auto_include

  def show

    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      #set_flash_message!(:notice, :confirmed)
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      # respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
     redirect_to root_path(:errors => resource.errors.messages)

    end
  end
  private

  def after_confirmation_path_for(resource_name, resource)

    root_path(:confirm => "Your account confirmed successfully. You can now login to access the features.")
  end

end
