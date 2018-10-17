# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.

require "omniauth-facebook"
require "omniauth-google-oauth2"
Devise.setup do |config|

  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'


  require 'devise/orm/active_record'

  #config.http_authenticatable_on_xhr = false
  #config.navigational_formats = ["*/*", :html, :json]
  config.warden do |manager|
    manager.failure_app = CustomFailure
  end

  config.secret_key = 'dab3164ee35b9cc6d8a9b93174181ef357e6b5c2ae6ac1401d594d6a7a357151768e3d312afc59ca43a65531909081ec7c72a5e9ffbb0266ac8f983b9d0f2e99'

  config.case_insensitive_keys = [:email]


  config.strip_whitespace_keys = [:email]


  config.skip_session_storage = [:http_auth]


  config.stretches = Rails.env.test? ? 1 : 10

  config.sign_out_via = :get
  config.reconfirmable = true

  config.allow_unconfirmed_access_for = 365.days

  config.expire_all_remember_me_on_sign_out = true

  config.scoped_views = true

  config.password_length = 8..72
  config.reconfirmable = false

  config.reset_password_within = 6.hours


  # config.omniauth :facebook, "1669287630013056", "cfc5d31d208220511507ad3daef6c982",:scope => 'email,public_profile'
  config.omniauth :facebook, "757515367716038", "aa16c3ae8653ece85d4096aa7593f75b",:scope => 'email,public_profile'

  # config.omniauth :google_oauth2,"878601507019-pucvlqm4tmn89ftsd8onvrodohqd2ggs.apps.googleusercontent.com", "V_YuE6FcWI5J937QB61VOzTj" ,skip_jwt: true
  config.omniauth :google_oauth2,"192269020572-33fcvcrofj8v6547l5vesq3vqd8to6oa.apps.googleusercontent.com", "M2t3uuvdvxJ96N57Djhq1kKc" ,skip_jwt: true

end
