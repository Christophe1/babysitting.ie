# == Schema Information
#
# Table name: users
#
#  id                     :integer(4)      not null, primary key
#  email                  :string(255)     default(""), not null
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  provider               :string(20)
#  external_user_id       :integer(8)
#  name                   :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  encrypted_password     :string(255)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  address                :text
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  lat                    :decimal(12, 9)
#  lng                    :decimal(12, 9)
#  address_visible        :boolean(1)      default(FALSE), not null
#  city                   :string(255)
#

class User < ActiveRecord::Base

  OMNI_AUTH_PROVIDERS = [SocialNetwork::FACEBOOK]
  FAR_AWAY = 100_000

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :omniauthable, :validatable, :confirmable

  acts_as_mappable :default_units => :kms, :default_formula => :sphere

  has_many :friend_relations, :primary_key => :external_user_id,
           :foreign_key => "source_user_id", :dependent => :destroy
  has_many :reviews
  has_many :email_invites, :foreign_key => :from_user_id, :dependent => :destroy

  has_many :genres
  has_many :film_users, :dependent => :destroy
  has_many :films, :through => :film_users

  validates :name, :allow_blank => true, :length => { :maximum => 50 }
  validates_presence_of :first_name
  validates_presence_of :last_name

  attr_accessible :email, :provider, :external_user_id, :name, :first_name, :last_name, :password_confirmation, :password, :first_name, :last_name,
                  :remember_me, :address, :confirmed_at, :lng, :lat, :address_visible, :city, :invites_count

  scope :from_facebook, where(:provider => SocialNetwork::FACEBOOK)
  scope :by_facebook_id, lambda { |facebook_id| from_facebook.where(:external_user_id => facebook_id) }
  scope :with_films, includes(:films)
  scope :followers_for, lambda { |user| where ['external_user_id IN (?) OR id IN (?)', user.facebook_followers_ids, user.followers_ids] }
  scope :following_by,  lambda { |user| where ['external_user_id IN (?) OR id IN (?)', user.facebook_followed_ids,  user.followed_ids] }

  self.per_page = 10

  class << self
    # Finds user by facebook token or creates a new one.
    #
    # @param access_token [OmniAuth::AuthHash] auth hash.
    #
    def find_for_facebook_oauth(access_token)
      user_info = access_token.extra.raw_info
      user = User.by_facebook_id(user_info.id).first
      if user.nil?
        user = self.find_or_initialize_by_email(user_info.email)
        password = Devise.friendly_token[0,6]
        user.update_attributes({
          :confirmed_at => Time.now,
          :provider => access_token.provider,
          :external_user_id => user_info.id,
          :name => user_info.try(:name),
          :first_name => user_info.try(:first_name),
          :last_name => user_info.try(:last_name),
        }.merge(user.new_record? ? {:password => password, :password_confirmation => password,} : {}))
        FacebookWorker.update_friends(user_info.id, access_token.credentials.token)
      else
        user.update_attributes({
          :email => user_info.email,
          :name => user_info.try(:name),
          :first_name => user_info.try(:first_name),
          :last_name => user_info.try(:last_name)
        })
      end
      user
    end

    def facebook_users_in_app(external_user_ids)
      User.where(:provider => SocialNetwork::FACEBOOK, :external_user_id => external_user_ids)
    end
  end

  #  Returns distance to another user in kilometers
  #
  #  @return [Float] amount of kilometers between users or FAR_AWAY if smth is wrong
  #
  def distance_to(user_or_review)
    return FAR_AWAY if [self.lat, self.lng, user_or_review.lat, user_or_review.lng].any?{|v| v.blank? }
    a = Geokit::LatLng.new(self.lat, self.lng)
    b = Geokit::LatLng.new(user_or_review.lat, user_or_review.lng)
    a.distance_to(b, :units => :kms)
  #rescue
  #  FAR_AWAY
  end

  # Overrides user string representation.
  #
  def to_s
    name || email
  end

  # Gets user first name.
  #
  def first_name
    super || (name and name.split.first)
  end

  #  returns name or first_name + last_name
  #
  def front_name
    name || "#{first_name} #{last_name}"
  end

  # Gets user last name.
  #
  def last_name
    super || (name and name.split.last)
  end

  # Determines whether user completed his profile on registration or not
  #
  def registration_complete?
    self.address.present?
  end

  # Returns true if user logged in using FB or attached his FB acc later.
  #
  def added_fb_account?
    !self.external_user_id.nil?
  end

  # Gets facebook friends ids of current user.
  #
  # @return [Array] list of facebook ids.
  #
  def facebook_friends_ids
    @facebook_friends_ids ||= begin
      FriendRelation.facebook.by_source_user(self.external_user_id).pluck(:target_user_id) +
      FriendRelation.facebook.by_target_user(self.external_user_id).pluck(:source_user_id)
    end
  end

  def facebook_followed_ids
    FriendRelation.facebook.by_source_user(self.external_user_id).pluck(:target_user_id)
  end

  def facebook_followers_ids
    FriendRelation.facebook.by_target_user(self.external_user_id).pluck(:source_user_id)
  end

  # Gets facebook friends ids of current user.
  #
  # @return [Array] list of facebook ids.
  #
  def email_friends_ids
    @email_friends_ids ||= begin
      FriendRelation.email.by_source_user(self.id).pluck(:target_user_id) +
      FriendRelation.email.by_target_user(self.id).pluck(:source_user_id)
    end.uniq
  end

  def followed_ids
    @followed_users_ids ||= begin
      FriendRelation.populisto.by_source_user(self.id).pluck(:target_user_id) +
      FriendRelation.email.by_source_user(self.id).pluck(:target_user_id)
    end
  end

  def followers_ids
    @followers_ids ||= begin
      FriendRelation.populisto.by_target_user(self.id).pluck(:source_user_id) +
      FriendRelation.email.by_target_user(self.id).pluck(:source_user_id)
    end
  end

  def invited_emails
    email_invites.pluck(:email).compact.map { |email| [email, email] }
  end

  # Gets facebook friends of current user that installed current facebook application.
  #
  # @return [Array] list of application users which friends with current user on facebook.
  #
  def facebook_friends
    @facebook_friends ||= User.where(:external_user_id => facebook_friends_ids)
  end

  # Gets all friends of current user
  #
  # @return [Array] list of application users which are friends on FB or locally
  #
  def all_friends
    User.where ['external_user_id IN (?) OR id IN (?)', facebook_friends_ids, email_friends_ids]
  end

  # Gets limited count of facebook friends of current user that installed current facebook application.
  #
  # @param limit [Fixnum] maximum friends count.
  #
  # @return [Array] list of application users which friends with current user on facebook.
  #
  def random_facebook_friends(limit)
    friends = facebook_friends
    friends_count = friends.count
    if limit < friends_count
      friends = friends.offset(rand(friends_count - limit + 1))
    end
    friends.limit(limit).all.shuffle
  end

  # Gets ids of neighbors on facebook (friends of friends).
  #
  # @param depth [Fixnum] depth of friends to check. If depth = 1 it return only friends,
  #                       if depth = 2 it returns friends + friends of friends
  #
  # @return [Array] list of facebook ids.
  #
  def facebook_neighbors_ids(depth = 2)
    result = facebook_friends_ids
    next_level = result
    while depth > 1
      next_level = FriendRelation.facebook.by_source_user(next_level).pluck(:target_user_id) +
      FriendRelation.facebook.by_target_user(next_level).pluck(:source_user_id)
      result += next_level
      depth -= 1
    end
    result - [self.external_user_id]
  end

  # Gets facebook neighbors of current user that installed current facebook application.
  #
  # @param depth [Fixnum] depth of friends to check. If depth = 1 it return only friends,
  #                       if depth = 2 it returns friends + friends of friends
  #
  # @return [Array] list of facebook ids.
  #
  def facebook_neighbors(depth = 2)
    User.where(:external_user_id => facebook_neighbors_ids(depth))
  end

  def facebook_mutual_friends_ids(user)
    facebook_friends_ids & user.facebook_friends_ids
  end

  def following?(other_user)
    FriendRelation.by_source_user(self.id).by_target_user(other_user.id) +
    FriendRelation.facebook.by_source_user(self.external_user_id).by_target_user(other_user.external_user_id)
  end

  def follow!(other_user)
    FriendRelation.create(:source_user_id => self.id,
                          :target_user_id => other_user.id,
                          :provider => SocialNetwork::POPULISTO,
                          :distance => self.distance_to(other_user) )
  end

  def unfollow!(other_user)
    FriendRelation.where(:source_user_id => [self.id, self.external_user_id]).where(:target_user_id => [other_user.id, other_user.external_user_id]).destroy_all
  end

  def can_follow?(other_user)
    self.distance_to(other_user) <= 20
  end

  def feed
    Review.from_users_followed_by(self)
  end

  def reposted_ids
    reviews.pluck(:repost_from).compact
  end

  def reject review
    reviews.find_by_repost_from(review.id).destroy
  end

  def increase_invites_count!(contacts_count)
    update_attributes(:invites_count => invites_count + contacts_count)
  end

end
