class InviteEmail < ActionMailer::Base
  layout "mailer"

  default :from => "noreply@populisto.com"

  def invite(email, custom_text, from_user, token)
    @custom_text = custom_text
    @from_user = from_user
    @token = token
    mail(:to => email, :subject => I18n.t('mailer.invite_email.subject', :name => from_user.front_name))
  end

  def reminder(email, sender_name, days_count, token)
    @sender_name = sender_name
    @token = token
    @days_count = days_count
    mail(:to => email, :subject => I18n.t('mailer.reminder_email.subject', :name => sender_name))
  end

end
