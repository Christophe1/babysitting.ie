# == Schema Information
#
# Table name: films
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Film < ActiveRecord::Base

  SUGGESTIONS_COUNT = 10

  has_many :film_genres, :dependent => :destroy
  has_many :genres, :through => :film_genres

  has_many :film_users, :dependent => :destroy
  has_many :users, :through => :film_users

  validates :name, :presence => true, :length => { :maximum => 50 }, :uniqueness => true

  attr_accessible :name, :genre_ids

  scope :start_with, lambda { |word| where("name like ?", "#{word}%") }
  scope :not_in, lambda { |film_ids| film_ids.present? ? where("id not in (?)", Array(film_ids)) : scoped }
  scope :with_genres, includes(:genres)
  scope :with_users, includes(:users)
  scope :by_genre, lambda { |genre_id| where(:id => FilmGenre.where(:genre_id => genre_id).pluck(:film_id)) }
  scope :from_facebook_neighbors, lambda { |user| where(:id => FilmUser.where(:user_id => user.facebook_neighbors.pluck(:id)).pluck(:film_id)) }

  self.per_page = 10

  # Overrides film string representation.
  #
  def to_s
    name
  end

  # Gets genres list.
  #
  def genres_list
    genres.map(&:name).join(", ")
  end

  class << self

    # Gets suggestions for film name autocomplete.
    #
    # @param query [String] start of film name.
    # @param user_id [Fixnum] user id.
    #
    # @return [Array] list of film names limited by Film::SUGGESTIONS_COUNT
    #
    def suggestions(query, user_id)
      start_with(query).with_genres.limit(SUGGESTIONS_COUNT).map do |film|
        {
            :id => film.id,
            :name => film.name,
            :genre_ids => film.genre_ids
        }
      end
    end
  end
end
