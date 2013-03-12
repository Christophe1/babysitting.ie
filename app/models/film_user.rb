# == Schema Information
#
# Table name: films_users
#
#  id         :integer(4)      not null, primary key
#  film_id    :integer(4)
#  user_id    :integer(4)
#  comments   :text
#  created_at :datetime
#  updated_at :datetime
#

class FilmUser < ActiveRecord::Base
  self.table_name =  :films_users

  belongs_to :film
  belongs_to :user
  has_many :film_user_genres, :dependent => :destroy
  has_many :genres, :through => :film_user_genres

  validates :film, :presence => true
  validates :user, :presence => true
  validates :comments, :presence => true, :length => { :maximum => 1000 }
  validates :genre_ids, :presence => true

  attr_accessible :film_id, :user_id, :comments, :film_attributes, :genre_ids
  accepts_nested_attributes_for :film

  scope :with_film, includes(:film)
  scope :with_user, includes(:user)
  scope :by_genre, lambda { |genre_id| where(:id => FilmUserGenre.where(:genre_id => genre_id).pluck(:film_user_id)) }
  scope :from_facebook_neighbors, lambda { |user| where(:user_id => user.facebook_neighbors.pluck(:id)) }
  scope :from_facebook_neighbors_and_me, lambda { |user| where(:user_id => user.facebook_neighbors.pluck(:id) + [user.id]) }
  scope :descending, order('updated_at DESC')

  self.per_page = 5

  # Gets genres list.
  #
  def genres_list
    genres.map(&:name).join(", ")
  end

  # Creates duplicate of film user review and assign it to specified user.
  #
  # @param user [User] target user.
  #
  # @return [FilmUser] new created film user.
  #
  def duplicate(user)
    copy = self.dup
    copy.user = user
    copy.genre_ids = self.genre_ids
    copy.save
  end
end
