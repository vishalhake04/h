Rails.application.routes.draw do

  # devise_for :admins
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  get '/dashboard' => "rails_admin/main#dashboard", :as => :dashboard
  get 'home/index'
  get '/reddera_way' => 'home#reddera_way'
  get '/professional_sign_up' => 'home#prof_sign_up'

  get'/card_destroy/:token_value'=>'users#card_destroy' ,:as=>'card_destroy'
  get 'corporate'=>'home#corporate'
  get '/faqs' => 'home#faqs'
  get '/safety' => 'home#safety'
  devise_for :users, :controllers => {:omniauth_callbacks => "callbacks", :registrations => "registrations",:confirmations=>"confirmations",:passwords => "passwords"}
  post '/users/:stylist_id/services/:service_id/bookings' => "bookings#create"
  devise_scope :users do
    get "sign_out", :to => "devise/sessions#destroy"
  end
  root 'home#index'
  match '/stylist/:id/:name'=> 'users#stylist_profile' , :via => [:get],:as=>'stylist'
  match '/client/:id/:name' => 'users#client_profile', :via => [:get],  :as=>'client'
  resources :gift_cards

  get '/gift_card_payment' => 'transactions#gift_card_payment'
  post '/gift_card_payment_create' => 'transactions#gift_card_payment_create'
  post '/pay_via_gift_card' => 'transactions#pay_via_gift_card',:as=>"pay_gift_card"

  resources :users do
    resources :favourite_stylist, :only=>[:index]
    resources :gift_cards ,:only=>[:create]
    post '/update_availability' ,to: 'update_availabilities#create' ,:as=>'create_updated_availabilities'
    get '/edit_updated_availabilities/:id' => 'update_availabilities#edit_updated_availabilities',:as=>'edit_updated_availabilities'
    delete '/delete_update_availability/:id' => 'update_availabilities#delete_update_availabilities',:as=>'delete_updated_availabilities'
    put 'payment_info' => 'payout_infos#payment_info'
    get 'dashboard' => 'users#dashboard'
    post 'service_list' => 'services#create_service'
    resources :services,:except=>[:create,:destroy]
    put 'destroy_service/:id' => 'services#destroy_service' ,:as=>'destroy_service'
    resources :previous_works
    resources :availabilities, :only=>[:index]
    put 'availability/update' => 'availabilities#update_availabilities'
    resources :bookings, :only=>[:update,:index,:destroy]
    post '/multiple_service_bookings' => 'bookings#multiple_bookings'
    put '/bookings/:id/reschedule' => 'bookings#reschedule',:as=>"reschedule"
    put '/bookings/:id/reschedule_stylist' => 'bookings#reschedule_stylist',:as=>'reschedule_stylist'
    put '/bookings/:id/reschedule_confirm' => 'bookings#reschedule_confirm_client',:as=>'rereschedule_confirm_client'
    put '/bookings/:id/booking_delete' => 'bookings#booking_delete',:as=>"delete"
    put '/bookings/:id/reschedule_confirm_by_stylist' => 'bookings#reschedule_confirm_by_stylist',:as=>'reschedule_confirm_by_stylist'
    resources :reviews,:only=>[:new,:create,:index]
    get 'sytist'=>'users#stylist_login'
  end

  post '/complaint/email'=>'users#complaint_email',:as=>"complaint"
  post '/inquiry/email'=>'users#inquiry_email',:as=>"inquiry"
  put '/delete_unavail_date/:date' => 'update_availabilities#delete_unavail' ,:as=>'delete_unavail'
  post '/transaction_create_testing'=>'transactions#create_transaction',:as=>'create_transaction'
  resource :service_categories,:only=>[:new,:create]
  resource :service_sub_categories,:only=>[:new,:create]
  resource :popular_services,:only=>[:new]
  put '/popular_service/:id' => 'popular_services#update',:as=>'popular_service'
  post '/users/:stylist_id/services/:service_id/reschedule_booking_client' => "bookings#reschedule_client",:as=>'reschedule_client'
  get '/service_categories/:id/service_sub_categories/:name' => 'service_categories#get_sub_categories_by_service_category' ,:as=>'service_category_sub_categories'
  post '/update_updated_availabilities/' => 'update_availabilities#update_updated_availabilities', :as=>'update_availability'
  #get 'client/:id' => 'users#client_profile',:as =>'client'
  resources :transactions, only: [:new, :create,:index,:destroy]
  post 'discounted_price'=>'transactions#discounted_price' ,:as=> 'discounted_price'
  post '/add_payment_method' => 'transactions#add_payment_method'
  post 'users/sms' => 'users#sms'
  get '/search'=> 'services#search'
  post '/sort_services'=> 'services#sort_services'
  post 'users/verify' => "users#sms_verified"
  resource :promo_codes, only: [:new,:create]
  delete '/promo_code/:id' => 'promo_codes#delete',:as=>'code_delete'
  post 'create_favourite_list' => 'favourite_stylist#create_favourite_list'
  post 'unfavourite_list' => 'favourite_stylist#unfavourite_list'

  post 'message'=> 'users#create_message'
  resource :user, only: [:edit] do
    collection do
      patch 'update_password'
    end
  end
  get '/featured_professionals/new' => 'featured_professionals#new'
  put '/featured_professional_update/:id' => 'featured_professionals#update',:as=>'featured_professionals_update'
  put '/recently_booked_update/:id'=>'recently_bookeds#update' ,:as=>"rec_book_update"
  get '/recently_booked/new' => 'recently_bookeds#new'
  post 'cities/:state', to: 'services#cities' ,:as=>'cities'
  get '/how_it_works'=> 'home#how_it_works',:as=>'how_it_works'
  get '/help'=> 'home#help',:as=>'help'
  get '/service_name'=>'home#service_category_name',:as=>'service_name'
  get '/inbox'=>'home#inbox',:as=>'inbox'
  resources :home do
    get :autocomplete_service_category_name, :on => :collection
  end


  namespace :api do
    namespace :v1 do
      get '/promo_codes'=>'promo_codes#index'
      get '/code_validity/:id'=>'promo_codes#code_validity'
      resources :services, only: [:index, :create, :show, :update, :destroy]
      get '/earnings'=>'bookings#earnings_for_month'
      post '/get_uuid'=>'users#get_uuid'
      post '/calc_tax'=>'transactions#calculate_tax'
      get 'favourite_stylists' => 'favourite_stylist#index'
      post '/favourite_stylist' => 'favourite_stylist#create_favourite_list'
      post '/unfavourite_stylist' => 'favourite_stylist#unfavourite_list'
      post 'users/sms' => 'users#sms'
      post 'discounted_price'=>'transactions#discounted_price' ,:as=> 'discounted_price'
      post 'users/verify' => "users#sms_verified"
      get '/users-by-service/:id' =>'services#getUsersByservice'
      post '/multiple_professionals' =>'services#getProfessionalsByMultipleSubServices'
      get 'services-by-userid/:user_id' => 'services#servicesByUserId'
      get 'service_categories/:id/sub_services'=>'services#get_sub_services_clubbed_services_f_service_category_id'
      resources :previous_works, only: [:create,:show, :update, :destroy]
      put '/users/update'=>'users#update'
      get '/user_info' => 'users#user_info'
      post '/users/update_password'=>'users#update_password'
      get 'works-by-userid/:user_id' => 'previous_works#worksByUserId'
      get '/search'=> 'services#search'
      resources :transactions, only: [:create,:index,:new]
      resources :bookings,only: [:index,:update,:create]
      put '/bookings/:id/reschedule' => 'bookings#reschedule',:as=>"reschedule"
      put '/bookings/:id/reschedule_by_stylist' => 'bookings#reschedule_stylist'
      put '/bookings/:id/reschedule_by_client' => 'bookings#reschedule_client'
      put '/bookings/:id/reschedule_confirm_client'=>'bookings#reschedule_confirm_client'
      put '/bookings/:id/reschedule_confirm_stylist'=>'bookings#reschedule_confirm_stylist'
      resources :photos,only: [:create]
      get 'services-by-userid/:user_id/sort-services'=>'services#get_sorted_services'
      post '/message_client'=> 'users#create_message_client'
      post '/message_stylist'=> 'users#create_message_stylist'
      get '/read_messages'=> 'users#read_messages'
      put 'availability/update' => 'availabilities#update_availabilities'
      resources :availabilities , only: [:index]
      resources :reviews,:only=>[:create]
      resources :gift_cards,:only=>[:create]
      resources :service_categories ,only: [:index]

      post '/pay_via_gift_card' => 'transactions#pay_via_gift_card',:as=>"pay_gift_card"
      post '/gift_card_payment_create' => 'transactions#gift_card_payment_create'
      get '/service_categories/:id/service_sub_categories' => 'service_sub_categories#get_sub_categories_by_service_category' ,:as=>'service_category_sub_categories'
      get 'reviews-by-userid/:user_id' => 'reviews#reviewsByUserId'
      resources :update_availabilities ,only:[:create]
      put '/bookings/:id/booking_delete' => 'bookings#booking_delete',:as=>"delete"
      post '/notifications_settings'=>'users#notification_settings'
      get '/notifications_settings' => 'users#get_settings_of_notifications'
      devise_scope :user do
  		  post 'registrations' => 'registrations#create', :as => 'register'
        post 'facebook-callbacks' => 'registrations#facebook',:as=>'facebook-callbacks'
        post 'google-callbacks' => 'registrations#google_oauth2',:as=>'google-callbacks'
        post 'sessions' => 'sessions#create', :as => 'login'
  		  delete 'sessions' => 'sessions#destroy', :as => 'logout'
  	  end

    end
  end

end
