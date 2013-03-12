class FriendRelation < ActiveRecord::Base
  belongs_to :source_user, :class_name => User.name
  belongs_to :target_user, :class_name => User.name

  validates :source_user_id, :presence => true
  validates :target_user_id, :presence => true
  validates :provider, :presence => true, :length => { :maximum => 20 }

  attr_accessible :target_user_id, :source_user_id, :provider, :distance

  scope :facebook, where(:provider => SocialNetwork::FACEBOOK)
  scope :email, where(:provider => SocialNetwork::EMAIL)
  scope :populisto, where(:provider => SocialNetwork::POPULISTO)
  scope :inner_provider, where(:provider => [SocialNetwork::EMAIL, SocialNetwork::POPULISTO])
  scope :by_source_user, lambda { |source_user_id| where(:source_user_id => source_user_id) }
  scope :by_target_user, lambda { |target_user_id| where(:target_user_id => target_user_id) }
  scope :within, lambda { |kms| where("distance < ?", kms) }
  scope :followed_users_by, lambda { |user| where ['(source_user_id = ? and provider = ?) or (source_user_id = ? and provider in (?))', user.external_user_id, SocialNetwork::FACEBOOK, user.id, [SocialNetwork::EMAIL, SocialNetwork::POPULISTO]] }
  scope :followers_with, lambda { |user| where ['(target_user_id = ? and provider = ?) or (target_user_id = ? and provider in (?))', user.external_user_id, SocialNetwork::FACEBOOK, user.id, [SocialNetwork::EMAIL, SocialNetwork::POPULISTO]] }

  # TODO: currently IDs are stored in 2 ways: as external and internal:
  #
  # <FriendRelation id: 71, provider: "facebook", source_user_id: 1742797356, target_user_id: 100003642125603>,
  # <FriendRelation id: 72, provider: "facebook", source_user_id: 1742797356, target_user_id: 100003833802119>,
  # <FriendRelation id: 73, provider: "email", source_user_id: 5, target_user_id: 8>,
  # <FriendRelation id: 74, provider: "email", source_user_id: 5, target_user_id: 9>]

  class << self
    # Updates user friends.
    #
    # @param source_user_id [Fixnum] source user external user id.
    # @param target_user_ids [Array] list of target users external user id.
    # @param provider [String] social network id.
    #
    # @return [Array] created relations.
    #
    def update_friends(source_user_id, target_user_ids, provider)
      transaction do
        by_source_user(source_user_id).where(:provider => provider).delete_all
        target_user_ids.each do |target_user_id|
          FriendRelation.create(:source_user_id => source_user_id, :target_user_id => target_user_id, :provider => provider)
        end
      end
    end

    # Adds friends. Does not delete all existing
    #
    # @param source_user_id [Fixnum] source user external user id.
    # @param target_user_ids [Array] list of target users external user id.
    # @param provider [String] social network id.
    #
    # @return [Array] created relations.
    #
    def add_friends(source_user_id, target_user_ids, provider)
      transaction do
        source_user = User.find(source_user_id)
        target_user_ids.each do |target_user_id|
          target_user = User.find(target_user_id)
          FriendRelation.create(:source_user_id => source_user_id, 
                                :target_user_id => target_user_id, 
                                :provider => provider,
                                :distance => source_user.distance_to(target_user) )
        end
      end
    end

    def add_reverse_friends(source_user_id, target_user_ids, provider)
      transaction do
        source_user = User.find(source_user_id)
        target_user_ids.each do |target_user_id|
          target_user = User.find(target_user_id)
          FriendRelation.create(:source_user_id => target_user_id, 
                                :target_user_id => source_user_id, 
                                :provider => provider,
                                :distance => source_user.distance_to(target_user) )
        end
      end
    end

    def update_distances(user)
      transaction do
        relations = FriendRelation.followed_users_by(user)
        relations.each do |relation|
          target_user = relation.followed_user
          relation.update_attributes(:distance => user.distance_to(target_user)) if target_user
        end
        relations = FriendRelation.followers_with(user)
        relations.each do |relation|
          source_user = relation.follower
          relation.update_attributes(:distance => user.distance_to(source_user))
        end
      end
    end
  end

  def followed_user
    case provider
      when SocialNetwork::FACEBOOK
        User.find_by_external_user_id target_user_id
      else
        User.find_by_id target_user_id
      end
  end

  def follower
    case provider
    when SocialNetwork::FACEBOOK
      User.find_by_external_user_id source_user_id
    else
      User.find_by_id source_user_id
    end      
  end
  
end


# == Schema Information
#
# Table name: friend_relations
#
#  id             :integer(4)      not null, primary key
#  provider       :string(255)
#  source_user_id :integer(8)
#  target_user_id :integer(8)
#  distance       :float           default(100000.0), not null
#

