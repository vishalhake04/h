require Rails.root.join('lib', 'rails_admin_publish.rb')
RailsAdmin.config do |config|

  RailsAdmin.config do |config|
    config.authenticate_with do
      warden.authenticate! scope: :user
    end
    config.current_user_method(&:current_user)

    config.authorize_with do
      redirect_to main_app.root_path unless current_user.admin?
    end



  end
  config.navigation_static_links = {
      'Add Service Category' => '/service_categories/new', #or whatever you used to mount RailsAdmin in your routes file
      'Add Service Sub Category' => '/service_sub_categories/new',
      'Add Popular Services'=>'/popular_services/new',
      'Add Recently Booked'=>'/recently_booked/new',
      'Add Featured Professionals'=>'/featured_professionals/new',
      'Add Promo Code'=>'/promo_codes/new'

  }


  #
  # module RailsAdmin
  #   module Config
  #     module Actions
  #       class Publish < RailsAdmin::Config::Actions::Base
  #         RailsAdmin::Config::Actions.register(self)
  #       end
  #     end
  #   end
  # end
  #
  #
  #
  # ### Popular gems integration
  #
  # ## == Devise ==
  # # config.authenticate_with do
  # #   warden.authenticate! scope: :user
  # # end
  # # config.current_user_method(&:current_user)
  #
  # ## == Cancan ==
  # # config.authorize_with :cancan
  #
  # ## == Pundit ==
  # # config.authorize_with :pundit
  #
  # ## == PaperTrail ==
  # # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0
  #
  # ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration
  #
  # config.actions do
  #   dashboard                     # mandatory
  #   index                         # mandatory
  #   new
  #   export
  #   bulk_delete
  #   show
  #   edit
  #   delete
  #   show_in_app
  #
  #   ## With an audit adapter, you can add:
  #   # history_index
  #   # history_show
  #   publish do
  #     # Make it visible only for article model. You can remove this if you don't need.
  #     visible do
  #       bindings[:abstract_model].model.to_s == "ServiceCategory"
  #     end
  #   end
  # end



end
