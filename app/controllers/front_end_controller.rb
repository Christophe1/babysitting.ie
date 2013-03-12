class FrontEndController < ApplicationController

  before_filter :authenticate_user!

  before_filter :force_address_step, :if => :user_signed_in?

  before_filter :check_friendship_token

  protected

  # Redirects user to Map page if address is not filled
  #
  def force_address_step
    redirect_to landing_page unless current_user.registration_complete?
  end

  #  Before filter, which should be used in case you want to include Google's Maps API to your page
  #
  def with_google_maps_api
    @include_goole_maps = true
  end

  #  Tries to create a relationship by token.
  #  Works for logged in users only
  #
  def check_friendship_token
    if user_signed_in? and cookies[:friendship_token]
      invite = EmailInvite.find_by_token(cookies[:friendship_token])
      if invite
        invite.confirm!(current_user)
        flash.now[:notice => I18n.t('email_invites.friendship_confirmed')]
      end
      cookies.delete :friendship_token
    end
  end

end
