class SearchController < FrontEndController

  before_filter :with_google_maps_api
  before_filter :default_miles_range
  before_filter :load_data_for_checkbox
  before_filter :fix_params, :only => :create

  def index
    @review = Review.new
  end

  def create
    @review = Review.new params[:review]
    @reviews = Review.scoped_by_search_params(params, current_user)
    render :action => :index
  end

  def change_range
    current_range = (params[:current_range] || default_range).to_i
    cookies[:kms_range] = new_range(current_range)
    redirect_to :action => :index
  end

  protected

  def default_miles_range
    @kms_range = (cookies[:kms_range] || default_range).to_i
  end

  private

  def fix_params
    params[:review] ||= {}
    params[:review][:search_ids] ||= []
    params[:review][:search_ids].reject!(&:blank?)
  end

  def load_data_for_checkbox
    categories = Category.fetch_all.map{|c| [c.name, "category_#{c.id}"] }    
    users_in_my_area = User.within(default_range, :origin => current_user)
    followers = users_in_my_area.followers_for(current_user)
    following = users_in_my_area.following_by(current_user)
    other = users_in_my_area - followers - following - [current_user]

    [followers, following, other].each do |users|
      users.map!{ |u| [u.front_name.to_s + '|' + u.city.to_s, "user_#{u.id}"] }
    end

    @data = [[I18n.t('search.group.category'), categories], 
             [I18n.t('search.group.followers_in'), followers],
             [I18n.t('search.group.following_in'), following],
             [I18n.t('search.group.other_people'), other]]
  end

  def default_range
    20
  end

  def new_range(old_range)
    {20 => 10, 10 => 20}[old_range]
  end

end
