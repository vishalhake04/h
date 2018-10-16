class Api::V1::PreviousWorksController < Api::V1::BaseController

  before_action :authenticate_user!, :only => [:create,:show, :update,:destroy,:modify_access!,:auth_to_create!]
  before_action :set_previous_work, only: [:show, :update, :destroy,:modify_access!]
  before_action :modify_access!, :only => [ :update,:destroy]
  before_action :auth_to_create!,:only=>[:create ,:update,:destroy]

  def show
    getPreviousWorksJson(@previous_work)
  end

  def create
    previous_work =current_user.previous_works.new(previous_work_params)

    if previous_work.save
      getPreviousWorksJson(previous_work)
    else
      render(json: { status: :unprocessable_entity, message: previous_work.errors })
    end
  end

  def update
    if @previous_work.update(previous_work_params)
      getPreviousWorksJson(@previous_work)
    else
      render(json: { status: :unprocessable_entity, message:@previous_work.errors })
    end
  end

  def destroy
    @previous_work.destroy
    render(json:{ message: 'Work was successfully destroyed.' }.to_json)
  end

  def worksByUserId
    begin
      works = User.find(params[:user_id]).previous_works
      getPreviousWorksListJson(works)
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  protected

  def getPreviousWorksListJson(previous_works)
	  render(
			json:previous_works,
				each_serializer: Api::V1::PreviousWorkSerializer


		)

  end

  def getPreviousWorksJson(previous_works)
    render(json: Api::V1::PreviousWorkSerializer.new(previous_works).to_json)
  end

  def auth_to_create!
    return (current_user.isStylist?) ? true : unauthenticated!
  end

  def set_previous_work
    begin
      @previous_work = PreviousWork.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end

  def previous_work_params
    params[:previous_work].permit(:legend,:description)
  end

  def modify_access!
    return current_user == @previous_work.user ? true : unauthenticated!
  end

end
