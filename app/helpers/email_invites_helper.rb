module EmailInvitesHelper
  def link_to_social(type)
    href = case type
      when 'gmail', 'yahoo', 'hotmail' then "/contacts/#{type}"
      when 'outlook', 'other_email' then "#"
      when 'linkedin' then @linkedin_url
    end
    link_to href do
      content_tag(:div, '', :class => "sn-icon #{type}") +
      content_tag(:div, I18n.t("email_invites.icon.#{type}"), :class => "sn-text")
    end
  end
end
