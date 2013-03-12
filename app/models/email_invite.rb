# == Schema Information
#
# Table name: email_invites
#
#  id           :integer(4)      not null, primary key
#  from_user_id :integer(4)
#  token        :string(255)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#  email        :string(255)
#  answer       :string(255)
#

class EmailInvite < ActiveRecord::Base

  attr_accessible :from_user_id, :email, :answer

  before_create :set_uniq_token

  INVITE_ANSWER = %w(accept cancel later)
  EMAIL_REGEXP = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i
  OUTLOOK_CONTENT_TYPES = ['text/csv', 'application/vnd.ms-excel']

  belongs_to :user, :foreign_key => :from_user_id

  scope :need_remind, where(:answer => ['accept', 'later'])
  scope :with_email, where('email IS NOT NULL')
  scope :accepted, where(:answer => 'accept')
  scope :remind_later, where(:answer => 'later')

  #  Sets unique token for invite
  #
  def set_uniq_token
    self.token = Digest::MD5.hexdigest "#{SecureRandom.hex(10)}-#{DateTime.now.to_s}"
  end

  # Confirms invite, adds relationship and destroys itself
  #
  def confirm!(user)
    FriendRelation.add_friends(self.from_user_id, [user.id], SocialNetwork::EMAIL)
    FriendRelation.add_reverse_friends(self.from_user_id, [user.id], SocialNetwork::EMAIL)
    self.destroy
  end

  def accept_invite!
    update_attributes(:answer => 'accept')
  end

  alias :cancel_invite! :destroy

  def later_invite!
    update_attributes(:answer => 'later')
  end

  # Returns emails from provided csv file.
  # @return [Array] list of emails
  #
  def self.contacts_from_outlook(file)
    if OUTLOOK_CONTENT_TYPES.include?(file.content_type)
      file_text = file.read
      CSV.parse(file_text).flatten.compact.map{ |i| i.match(EMAIL_REGEXP).try(:to_s) }.compact.uniq.map { |c| [c, c] }.to_json
    end
  end

end
