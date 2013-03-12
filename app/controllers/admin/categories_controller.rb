class Admin::CategoriesController < Admin::BaseController
  inherit_resources
  navigation_section :categories
  paginated

  def destroy
    destroy! { collection_url(:page => params[:page]) }
  end
end
