class Admin::ProfilesController < Admin::BaseController

  respond_to :html
  responders :flash

  def edit
    respond_with(@admin = current_admin)
  end

  def update
    @admin = current_admin
    if @admin.update_with_password(params[:admin])
      sign_in(:admin, @admin, :bypass => true)
    end
    respond_with(@admin, :location => admin_root_path)
  end

  protected

  def build_breadcrumbs
    @breadcrumbs = [{ :title => I18n.t('admin.sections.profile'), :url => edit_admin_profile_path }]
  end
end
