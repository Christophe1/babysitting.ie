# == Schema Information
#
# Table name: films_users_genres
#
#  id           :integer(4)      not null, primary key
#  film_user_id :integer(4)
#  genre_id     :integer(4)
#

class FilmUserGenre < ActiveRecord::Base
  self.table_name = :films_users_genres

  belongs_to :film_user
  belongs_to :genre

  validates :film_user, :presence => true
  validates :genre, :presence => true
end
