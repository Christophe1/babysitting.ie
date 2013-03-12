module EmailInvitesReminder
  @queue = :email_invites_reminder

  def self.perform()
    EmailInvite.need_remind.with_email.find_each do |invite|
      days_count = Time.current.day - invite.created_at.day
      InviteEmail.reminder(invite.email, invite.user.front_name, days_count, invite.token).deliver
    end
  end
end