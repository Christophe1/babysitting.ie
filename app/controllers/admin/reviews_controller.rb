class Admin::ReviewsController < Admin::BaseController
  inherit_resources
  navigation_section :reviews
  paginated

  before_filter :load_categories
  before_filter :with_google_maps_api, :only => [:edit, :new, :update]

  def destroy
    destroy! { collection_url(:page => params[:page]) }
  end

  protected

  def end_of_association_chain
    Review.with_user.with_categories
  end

  private

  def load_categories
    @categories = Category.all
  end
end