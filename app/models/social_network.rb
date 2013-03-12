class SocialNetwork
  module NetworkTypes
    FACEBOOK = 'facebook'
    EMAIL = 'email'
    POPULISTO = 'populisto'
    GMAIL = 'gmail'
    YAHOO = 'yahoo'
    HOTMAIL = 'hotmail'
    OTHER_EMAIL = 'other_email'
    OUTLOOK = 'outlook'
    LINKEDIN = 'linkedin'
  end

  include NetworkTypes
  FACEBOOK_INVITE_LIMIT = 50
end