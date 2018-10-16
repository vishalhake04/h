  class Api::V1::SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }
  skip_filter :verify_signed_out_user, only: :destroy
  respond_to :json
  before_action :authenticate!, only: [:create,:destroy]

  def create

    render :status => 200,
           :json =>  { :success => true,
                       :info => "Logged in", :data => { :auth_token => @current_user.authentication_token,:user=> Api::V1::UserSerializer.new(@current_user,root:false)  }}.to_json
  end

  def destroy

    @current_user.update_column(:authentication_token, generate_authentication_token)

    render :status => 200,
           :json => { :success => true,
                      :info => "Logged out",
                      :data => {} }.to_json
  end

  def failure

    render :status => 401,
           :json => { :success => false,
                      :info => "Request Failed",
                      :data => {} }.to_json
  end

  def authenticate!
    @current_user=nil
    if params[:action] == 'destroy'

      token, options = ActionController::HttpAuthentication::Token.token_and_options(request)
      current_user = User.find_by(authentication_token: token)
      @current_user=current_user.email==options[:email] ? current_user : nil if !current_user.blank?

      return !@current_user.blank? ? true : failure
    end
    @current_user = User.find_by_email(params[:user][:email]) if params[:action] == 'create'
    if @current_user.nil? || @current_user.confirmed_at.nil? || !@current_user.valid_password?(params["user"]["password"])
      failure
    else
      true
    end
  end

  def generate_authentication_token
    authentication_token=nil
    loop do
      authentication_token = SecureRandom.base64(64)
      break unless User.find_by(authentication_token: authentication_token)
    end
    return authentication_token
  end

end
