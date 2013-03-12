module EmailInvitesExtension

  include SocialNetwork::NetworkTypes

  # Send emails to specified addresses.
  # @param [Array] list of emails
  #
  def send_emails(contacts)
    @valid_emails = contacts.select { |e| e =~ Devise.email_regexp }
    @bad_emails = contacts - @valid_emails
    current_user.increase_invites_count!(@valid_emails.count)
    @valid_emails.each do |email|
      EmailInvite.transaction do
        invite = EmailInvite.create(:from_user_id => current_user.id, :email => email)
        InviteEmail.invite(email, params[:message], current_user, invite.token).deliver
      end
    end
  end

  # Send messages to specified linkedin users.
  # @param [Array] list of [user_name, linkedin_id]
  #
  def send_linkedin_message(contacts)
    @linkedin_client.authorize!(session)

    linkedin_profile_name = @linkedin_client.full_name
    subject = I18n.t('mailer.invite_email.subject', :name => linkedin_profile_name)
    current_user.increase_invites_count!(contacts.count)
    EmailInvite.transaction do
      invite = EmailInvite.create(:from_user_id => current_user.id)
      custom_message = I18n.t('email_invites.linkedin_custom', :name => linkedin_profile_name, :body => params[:message])
      body = I18n.t('email_invites.linkedin_message',
                    :name => linkedin_profile_name,
                    :link => confirm_email_invites_url(:token => invite.token, :answer => 'accept'),
                    :custom => custom_message)
      @linkedin_client.send_message(subject, body, contacts)
    end
  end

  def successfully_sent?
    @valid_emails.present? and @bad_emails.blank?
  end

  def redirect_after_send
    if params[:importer] == OTHER_EMAIL
      if successfully_sent?
        redirect_to landing_page, { :notice => I18n.t('email_invites.notification_sent') }
      else
        redirect_to landing_page, { :alert => I18n.t('email_invites.notification_sent_error') + "#{@bad_emails.to_sentence}" }
      end
    else
      render :json => { :message => I18n.t('email_invites.notification_sent'), :invites_count => current_user.invites_count }
    end
  end

  # Get contacts checked by user according to params[:importer].
  # @return [Array] list of emails or contacts
  #
  def fetch_contacts
    case params[:importer]
    when OTHER_EMAIL then params[:emails].split(',')
    when GMAIL, YAHOO, HOTMAIL, OUTLOOK, LINKEDIN then params[:contacts]
    end
  end

  # Parse response from social networks.
  # @return [Array] list of [email or linkedin_user_name, email or linkedin_id]
  #
  def parse_contacts
    case params[:importer]
    when GMAIL, YAHOO, HOTMAIL
      request.env['omnicontacts.contacts'].map { |c| [c[:email], c[:email]] }.to_json
    when LINKEDIN then fetch_linkedin_contacts
    end
  end

  def fetch_linkedin_contacts
    unless session[:atoken]
      pin = params[:oauth_verifier]
      session[:atoken], session[:asecret] = @linkedin_client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
    else
      @linkedin_client.authorize_from_access(session[:atoken], session[:asecret])
    end
    @linkedin_client.connections[:all].map { |c| ["#{c.first_name} #{c.last_name}", c[:id]] }.to_json
  end

end
