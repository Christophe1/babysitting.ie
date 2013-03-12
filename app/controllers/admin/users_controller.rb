class Admin::UsersController < Admin::BaseController
  inherit_resources
  navigation_section :users
  paginated

  before_filter :with_google_maps_api, :only => [:edit, :new]

  def update
    password_presence
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = I18n.t('admin.profile.edit.success')
      redirect_to admin_user_path @user
    else
      render :edit
    end
  end

  def destroy
    destroy! { collection_url(:page => params[:page]) }
  end

  protected

  def end_of_association_chain
    User.with_films
  end

  def password_presence
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
  end
end
