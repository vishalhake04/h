class FeaturedProfessionalsController < ApplicationController
  skip_after_filter :intercom_rails_auto_include
  def new

    if user_signed_in? && current_user.isAdmin?
      @featured_professional=FeaturedProfessional.order(:id)
    else
      not_found
    end
  end
  def update
    feat_prof=FeaturedProfessional.find(params[:id])
    feat_prof.update(:user_id=>params[:user])
    redirect_to featured_professionals_new_path
  end

  end
