class EmailInvitesController < ApplicationController

  include EmailInvitesExtension

  before_filter :authenticate_user!, :except => :confirm
  before_filter :init_linkedin_client, :only => [:index, :create, :contacts_callback]

  layout false

  def index
    @linkedin_url = @linkedin_client.authorize_url(session, contacts_callback_url(:linkedin))
  end

  # Handles POST with emails to send to
  def create
    contacts = fetch_contacts
    case params[:importer]
    when LINKEDIN then send_linkedin_message(contacts)
    when GMAIL, YAHOO, HOTMAIL, OUTLOOK, OTHER_EMAIL then send_emails(contacts)
    when FACEBOOK then current_user.increase_invites_count!(params[:sended_invites].to_i)
    end
    redirect_after_send
  end

  def confirm
    if params[:token] and params[:answer]
      check_invite_answer
    else
      redirect_to root_path, :alert => I18n.t('email_invites.token_missing')
    end
  end

  def contacts_callback
    @contacts = parse_contacts
  end

  def contacts_callback_failure
  end

  def invitation_form
    all_contacts = params[:contacts].values.sort
    invited_emails = current_user.invited_emails
    @contacts = all_contacts - invited_emails
    @invited = all_contacts & invited_emails
  end

  def outlook_import
    @contacts = EmailInvite.contacts_from_outlook(params[:file])
  end

  private

  def init_linkedin_client
    @linkedin_client = LinkedIn::Client.new(LinkedIn::Client::APP_KEY, LinkedIn::Client::APP_SECRET, LinkedIn::Client::CONFIGURATION)
  end

  def check_invite_answer
    invite = EmailInvite.find_by_token(params[:token])
    if EmailInvite::INVITE_ANSWER.include?(params[:answer]) and invite
      invite.send("#{params[:answer]}_invite!")
    end

    if params[:answer] == 'accept'
      cookies[:friendship_token] = params[:token]
      # For signed in users there is a filter *check_friendship_token*
      user_signed_in? ? redirect_to(landing_page) : redirect_to(new_user_registration_path)
    else
      redirect_to root_path, :notice => I18n.t("email_invites.#{params[:answer]}_invitation")
    end
  end

end
