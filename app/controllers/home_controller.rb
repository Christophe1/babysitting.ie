class HomeController < FrontEndController

  skip_before_filter :authenticate_user!, :only => :index
  before_filter :check_if_user_not_signed_in, :only => :index
  skip_before_filter :force_address_step, :only => [:index, :map, :update_address]

  before_filter :with_google_maps_api, :only => :map

  after_filter :update_distances_to_other_users, :only => :update_address

  #before_filter :load_data_for_checkbox



  def index
    render 'users/sessions/new', :layout => 'devise'
  end

  def map
    @review = Review.new
  end

  def update_address
    if params[:changed] == '1'
      current_user.update_attributes(params[:user]) 
      redirect_to landing_page
    else
      flash[:alert] = I18n.t('map.address_validation')
      redirect_to landing_page
    end
  end

  private

  def check_if_user_not_signed_in
    if user_signed_in?
      if current_user.registration_complete?
        redirect_to landing_page
      else
        redirect_to map_path
      end
    end
  end

  def update_distances_to_other_users
    FriendRelation.update_distances(current_user)
  end

end
