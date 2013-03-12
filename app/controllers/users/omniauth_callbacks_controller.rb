class Users::OmniauthCallbacksController < ApplicationController

  def facebook
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"])
    if @user.persisted?
      # flash[:notice] = I18n.t("devise.omniauth_callbacks.success", :kind => "Facebook")
      sign_in(@user, :event => :authentication)
      @redirect_path = after_sign_in_path_for(@user)
      respond_to do |format|
        format.js { render :action => 'success' }
        format.html { redirect_to @redirect_path }
      end
    else
      flash[:error] = I18n.t("devise.omniauth_callbacks.failure", :kind => "Facebook", :reason => "could not find or create account")
      respond_to do |format|
        format.js { render :action => 'error' }
        format.html { redirect_to root_path }
      end
    end
  end

end
