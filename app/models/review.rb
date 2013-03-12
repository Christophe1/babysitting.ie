# == Schema Information
#
# Table name: reviews
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  author_id   :integer(4)
#  name        :string(255)     not null
#  phone       :string(255)
#  comment     :text
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#  visible     :boolean(1)      default(TRUE)
#  address     :string(255)
#  lat         :decimal(12, 9)
#  lng         :decimal(12, 9)
#  repost_from :integer(4)
#

class Review < ActiveRecord::Base

  SUGGESTIONS_COUNT = 10

  has_many :category_reviews, :dependent => :destroy
  has_many :categories, :through => :category_reviews

  #has_many :film_users, :dependent => :destroy
  #has_many :users, :through => :film_users

  belongs_to :user

  validates :name, :presence => true, :length => { :maximum => 255 }
  validates :phone, :length => { :maximum => 30 }
  validates :comment, :length => { :maximum => 1000 }
  validates_presence_of :category_ids

  attr_accessible :comment, :name, :phone, 
                  :user_id, :category_ids, 
                  :address, :lng, :lat, 
                  :visible, :repost_from,
                  :search_ids
                  
  attr_accessor :distance, :search_ids

  default_scope :order => 'reviews.created_at DESC'
  scope :start_with, lambda { |word| where("name like ?", "#{word}%") }
  scope :with_categories, includes(:categories)
  scope :with_user, includes(:user)
  scope :by_category, lambda { |category_id| where(:id => CategoryReview.where(:category_id => category_id).pluck(:review_id)) }
  scope :from_followers, lambda { |user| where(:user_id => user.all_friends.map(&:id)) }
  scope :from_facebook_neighbors, lambda { |user| where(:user_id => user.facebook_neighbors.pluck(:id)) }

  before_create :set_author_id

  self.per_page = 10

  # Overrides film string representation.
  #
  def to_s
    name
  end

  # Gets genres list.
  #
  def categories_list
    categories.map(&:name).join(", ")
  end

  def repost(other_user)
    review = dup
    review.categories = categories
    review.update_attributes(:user_id => other_user.id, :comment => nil, :repost_from => self.id)
    review.save
  end

  class << self

    #  Prepares scope from search params.
    #  Scope can contain different category_ids, user_ids etc.
    #
    def scoped_by_search_params(params, current_user)
      if params[:review][:search_ids].present?
        scope = Review.with_user.with_categories
        filters = params[:review][:search_ids].select{ |f| f.present? }
        categories = filters.select{|f| f.starts_with?('category_') }.map{|f| f.gsub('category_','').to_i }
        users = filters.select{|f| f.starts_with?('user_') }.map{|f| f.gsub('user_','').to_i }
        scope = scope.where(:categories => {:id => categories}) unless categories.blank?
        scope = scope.where(:user_id => users) unless users.blank?
        reviews = scope.all
        # Stupid solution to reload all categories:
        reviews = Review.with_user.with_categories.where(:id => reviews.map(&:id)).all.select{|r| r.user.present? }
      end
    end
    
    def from_users_followed_by(user)
      followed_user_ids = "SELECT target_user_id FROM friend_relations
                           WHERE source_user_id = :user_id"
      where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", 
            :user_id => user.id)
    end

  end

  private

  #  Sets author_id to current user_id
  #
  def set_author_id
    if self.author_id.blank?
      self.author_id = self.user_id
    end
  end

end

